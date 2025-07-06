#!/bin/bash

# Claude Code 自动提交脚本
# 在每次Claude Code执行完毕后自动提交代码到仓库

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 日志文件
LOG_FILE="$PROJECT_ROOT/.claude-hooks/auto-commit.log"

# 创建日志目录
mkdir -p "$(dirname "$LOG_FILE")"

# 日志函数
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] ✅ $1${NC}" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ❌ $1${NC}" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️ $1${NC}" | tee -a "$LOG_FILE"
}

# 主函数
main() {
    log "🚀 开始Claude Code自动提交流程"
    
    # 进入项目目录
    cd "$PROJECT_ROOT" || {
        log_error "无法进入项目目录: $PROJECT_ROOT"
        exit 1
    }
    
    # 检查是否在Git仓库中
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "当前目录不是Git仓库"
        exit 1
    fi
    
    # 检查是否有未提交的更改
    if git diff --quiet && git diff --cached --quiet; then
        log_warning "没有检测到代码更改，跳过提交"
        exit 0
    fi
    
    # 获取当前分支
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    log "当前分支: $CURRENT_BRANCH"
    
    # 添加所有更改到暂存区
    log "添加文件到暂存区..."
    git add .
    
    # 生成提交信息
    COMMIT_MSG=$(generate_commit_message)
    log "生成提交信息: $COMMIT_MSG"
    
    # 提交更改
    log "提交更改..."
    if git commit -m "$COMMIT_MSG"; then
        log_success "代码已成功提交"
    else
        log_error "提交失败"
        exit 1
    fi
    
    # 推送到远程仓库
    log "推送到远程仓库..."
    if git push origin "$CURRENT_BRANCH"; then
        log_success "代码已成功推送到远程仓库"
    else
        log_error "推送失败"
        exit 1
    fi
    
    log_success "🎉 Claude Code自动提交流程完成！"
}

# 生成智能提交信息
generate_commit_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local files_changed=$(git diff --cached --name-only | wc -l | tr -d ' ')
    local lines_added=$(git diff --cached --numstat | awk '{add += $1} END {print add}')
    local lines_deleted=$(git diff --cached --numstat | awk '{del += $2} END {print del}')
    
    # 检测主要更改类型
    local change_type="refactor"
    if git diff --cached --name-only | grep -q "\.tsx\|\.ts\|\.js\|\.jsx"; then
        change_type="feat"
    elif git diff --cached --name-only | grep -q "\.md\|\.txt"; then
        change_type="docs"
    elif git diff --cached --name-only | grep -q "package\.json\|yarn\.lock\|package-lock\.json"; then
        change_type="deps"
    elif git diff --cached --name-only | grep -q "\.css\|\.scss\|\.sass"; then
        change_type="style"
    fi
    
    # 生成提交信息
    echo "${change_type}: Claude Code自动提交 - ${timestamp}

📊 变更统计:
- 文件修改: ${files_changed}个
- 新增行数: ${lines_added:-0}行
- 删除行数: ${lines_deleted:-0}行

🤖 由Claude Code自动生成和提交
⏰ 提交时间: ${timestamp}"
}

# 执行主函数
main "$@" 