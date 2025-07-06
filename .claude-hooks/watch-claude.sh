#!/bin/bash

# Claude Code 监控脚本
# 监控Claude Code的执行状态，在完成后自动提交代码

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 配置文件
CONFIG_FILE="$PROJECT_ROOT/.claude-hooks/config"

# 日志文件
LOG_FILE="$PROJECT_ROOT/.claude-hooks/watch.log"

# PID文件
PID_FILE="$PROJECT_ROOT/.claude-hooks/watch.pid"

# 默认配置
WATCH_INTERVAL=5  # 监控间隔（秒）
AUTO_COMMIT_ENABLED=true
AUTO_PUSH_ENABLED=true
IDLE_TIMEOUT=300  # 空闲超时时间（秒）

# 加载配置
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    fi
    
    # 环境变量覆盖
    if [ "$CLAUDE_AUTO_COMMIT" = "false" ]; then
        AUTO_COMMIT_ENABLED=false
    fi
    
    if [ "$CLAUDE_COMMIT_PUSH" = "false" ]; then
        AUTO_PUSH_ENABLED=false
    fi
}

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

# 检查是否有Claude Code相关进程
check_claude_processes() {
    # 检查常见的Claude Code相关进程
    local claude_processes=$(ps aux | grep -i "claude\|cursor\|vscode" | grep -v grep | grep -v "$0" | wc -l)
    echo $claude_processes
}

# 检查文件系统变化
check_file_changes() {
    cd "$PROJECT_ROOT" || return 1
    
    # 检查Git状态
    if git diff --quiet && git diff --cached --quiet; then
        return 1  # 没有变化
    else
        return 0  # 有变化
    fi
}

# 获取最后修改时间
get_last_modified_time() {
    find "$PROJECT_ROOT" -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.md" -o -name "*.json" \) -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/.claude-hooks/*" -printf '%T@\n' | sort -n | tail -1
}

# 执行自动提交
execute_auto_commit() {
    if [ "$AUTO_COMMIT_ENABLED" = "true" ]; then
        log "🚀 执行自动提交..."
        
        # 设置环境变量
        if [ "$AUTO_PUSH_ENABLED" = "false" ]; then
            export CLAUDE_COMMIT_PUSH=false
        fi
        
        # 执行提交脚本
        if "$PROJECT_ROOT/.claude-hooks/auto-commit.sh"; then
            log_success "自动提交完成"
            return 0
        else
            log_error "自动提交失败"
            return 1
        fi
    else
        log_warning "自动提交已禁用"
        return 0
    fi
}

# 主监控循环
start_watching() {
    log "🔍 开始监控Claude Code活动..."
    log "配置: 监控间隔=${WATCH_INTERVAL}s, 自动提交=${AUTO_COMMIT_ENABLED}, 自动推送=${AUTO_PUSH_ENABLED}"
    
    local last_modified_time=$(get_last_modified_time)
    local idle_start_time=$(date +%s)
    local last_check_time=$(date +%s)
    
    while true; do
        sleep $WATCH_INTERVAL
        
        current_time=$(date +%s)
        current_modified_time=$(get_last_modified_time)
        
        # 检查文件是否有变化
        if [ "$current_modified_time" != "$last_modified_time" ]; then
            log "📝 检测到文件变化"
            last_modified_time=$current_modified_time
            idle_start_time=$current_time
        fi
        
        # 检查是否进入空闲状态
        idle_duration=$((current_time - idle_start_time))
        
        if [ $idle_duration -ge $IDLE_TIMEOUT ]; then
            # 检查是否有未提交的变化
            if check_file_changes; then
                log "⏰ 检测到空闲状态，有未提交的变化"
                execute_auto_commit
                idle_start_time=$current_time
            fi
        fi
        
        # 每分钟输出一次状态
        if [ $((current_time - last_check_time)) -ge 60 ]; then
            log "📊 监控状态: 空闲时间=${idle_duration}s"
            last_check_time=$current_time
        fi
    done
}

# 停止监控
stop_watching() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            rm -f "$PID_FILE"
            log_success "监控已停止"
        else
            log_warning "监控进程不存在"
            rm -f "$PID_FILE"
        fi
    else
        log_warning "没有找到监控进程"
    fi
}

# 显示状态
show_status() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo -e "${GREEN}✅ 监控正在运行 (PID: $pid)${NC}"
        else
            echo -e "${RED}❌ 监控进程不存在${NC}"
            rm -f "$PID_FILE"
        fi
    else
        echo -e "${YELLOW}⚠️ 监控未运行${NC}"
    fi
}

# 主函数
main() {
    case "${1:-start}" in
        start)
            if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
                log_warning "监控已经在运行中"
                exit 0
            fi
            
            load_config
            
            # 后台运行
            if [ "$2" = "--daemon" ]; then
                nohup "$0" _start > /dev/null 2>&1 &
                echo $! > "$PID_FILE"
                log_success "监控已在后台启动"
            else
                echo $$ > "$PID_FILE"
                trap 'rm -f "$PID_FILE"; exit' INT TERM
                start_watching
            fi
            ;;
        _start)
            load_config
            start_watching
            ;;
        stop)
            stop_watching
            ;;
        restart)
            stop_watching
            sleep 2
            "$0" start --daemon
            ;;
        status)
            show_status
            ;;
        *)
            echo "用法: $0 {start|stop|restart|status}"
            echo ""
            echo "命令说明:"
            echo "  start          - 启动监控（前台运行）"
            echo "  start --daemon - 启动监控（后台运行）"
            echo "  stop           - 停止监控"
            echo "  restart        - 重启监控"
            echo "  status         - 显示监控状态"
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@" 