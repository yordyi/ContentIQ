#!/bin/bash

# Claude Code Hooks 设置脚本
# 用于安装和配置自动提交hooks

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${BLUE}🔧 Claude Code Hooks 设置程序${NC}"
echo "========================================"

# 检查是否在Git仓库中
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ 错误：当前目录不是Git仓库${NC}"
    exit 1
fi

# 创建hooks目录
echo -e "${BLUE}📁 创建hooks目录...${NC}"
mkdir -p "$PROJECT_ROOT/.claude-hooks"

# 设置脚本执行权限
echo -e "${BLUE}🔐 设置脚本执行权限...${NC}"
chmod +x "$PROJECT_ROOT/.claude-hooks/auto-commit.sh"

# 创建快捷命令
echo -e "${BLUE}⚡ 创建快捷命令...${NC}"
cat > "$PROJECT_ROOT/.claude-hooks/commit" << 'EOF'
#!/bin/bash
# Claude Code 快捷提交命令
cd "$(dirname "${BASH_SOURCE[0]}")/.."
./.claude-hooks/auto-commit.sh "$@"
EOF

chmod +x "$PROJECT_ROOT/.claude-hooks/commit"

# 创建package.json脚本
echo -e "${BLUE}📦 添加npm脚本...${NC}"
if [ -f "$PROJECT_ROOT/package.json" ]; then
    # 检查是否已存在claude-commit脚本
    if ! grep -q '"claude-commit"' "$PROJECT_ROOT/package.json"; then
        # 使用Node.js来修改package.json
        node -e "
        const fs = require('fs');
        const path = '$PROJECT_ROOT/package.json';
        const pkg = JSON.parse(fs.readFileSync(path, 'utf8'));
        pkg.scripts = pkg.scripts || {};
        pkg.scripts['claude-commit'] = 'bash .claude-hooks/auto-commit.sh';
        pkg.scripts['claude-setup'] = 'bash .claude-hooks/setup-hooks.sh';
        fs.writeFileSync(path, JSON.stringify(pkg, null, 2) + '\n');
        " 2>/dev/null || echo -e "${YELLOW}⚠️ 无法自动修改package.json，请手动添加脚本${NC}"
    else
        echo -e "${GREEN}✅ claude-commit脚本已存在${NC}"
    fi
fi

# 创建使用说明
echo -e "${BLUE}📝 创建使用说明...${NC}"
cat > "$PROJECT_ROOT/.claude-hooks/README.md" << 'EOF'
# Claude Code 自动提交系统

## 功能说明

这个系统会在Claude Code执行完毕后自动提交代码到Git仓库，包括：

- 🔍 检测代码变更
- 📝 生成智能提交信息
- 🚀 自动提交并推送到远程仓库
- 📊 提供详细的变更统计
- 📋 记录操作日志

## 使用方法

### 1. 手动触发提交

```bash
# 方法1：直接执行脚本
./.claude-hooks/auto-commit.sh

# 方法2：使用快捷命令
./.claude-hooks/commit

# 方法3：使用npm脚本
npm run claude-commit
```

### 2. 自动触发（推荐）

在Claude Code完成编码任务后，系统会自动检测变更并提交。

## 配置选项

### 环境变量

- `CLAUDE_AUTO_COMMIT`: 设置为 `false` 可禁用自动提交
- `CLAUDE_COMMIT_PUSH`: 设置为 `false` 可禁用自动推送

### 示例

```bash
# 禁用自动提交
export CLAUDE_AUTO_COMMIT=false

# 只提交不推送
export CLAUDE_COMMIT_PUSH=false
```

## 日志文件

所有操作都会记录到 `.claude-hooks/auto-commit.log` 文件中。

## 提交信息格式

自动生成的提交信息包含：

- 📊 变更统计（文件数、行数）
- 🏷️ 智能分类（feat/docs/style/deps等）
- ⏰ 时间戳
- 🤖 自动标记

## 故障排除

1. **权限问题**：确保脚本有执行权限
2. **Git配置**：确保Git用户名和邮箱已配置
3. **远程仓库**：确保有推送权限

## 卸载

删除 `.claude-hooks` 目录即可完全卸载。
EOF

# 创建.gitignore条目（如果需要）
echo -e "${BLUE}📄 配置.gitignore...${NC}"
if [ -f "$PROJECT_ROOT/.gitignore" ]; then
    if ! grep -q ".claude-hooks/auto-commit.log" "$PROJECT_ROOT/.gitignore"; then
        echo -e "\n# Claude Code Hooks\n.claude-hooks/auto-commit.log" >> "$PROJECT_ROOT/.gitignore"
    fi
fi

# 完成设置
echo ""
echo -e "${GREEN}🎉 Claude Code Hooks 设置完成！${NC}"
echo ""
echo -e "${BLUE}📋 可用命令：${NC}"
echo -e "  ${YELLOW}npm run claude-commit${NC}     - 手动执行提交"
echo -e "  ${YELLOW}./.claude-hooks/commit${NC}   - 快捷命令"
echo -e "  ${YELLOW}npm run claude-setup${NC}      - 重新运行设置"
echo ""
echo -e "${BLUE}📁 相关文件：${NC}"
echo -e "  ${YELLOW}.claude-hooks/auto-commit.sh${NC}  - 主要脚本"
echo -e "  ${YELLOW}.claude-hooks/README.md${NC}       - 使用说明"
echo -e "  ${YELLOW}.claude-hooks/auto-commit.log${NC}  - 操作日志"
echo ""
echo -e "${GREEN}✨ 现在Claude Code执行完毕后会自动提交代码！${NC}" 