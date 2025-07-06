# Claude Code 自动提交系统

## 功能说明

这个系统会在Claude Code执行完毕后自动提交代码到Git仓库，包括：

- 🔍 检测代码变更
- 📝 生成智能提交信息
- 🚀 自动提交并推送到远程仓库
- 📊 提供详细的变更统计
- 📋 记录操作日志

## 使用方法

### 1. 图形化管理界面（推荐）

```bash
# 启动管理界面
npm run claude-manage

# 或直接执行
./.claude-hooks/manage.sh
```

### 2. 手动触发提交

```bash
# 方法1：直接执行脚本
./.claude-hooks/auto-commit.sh

# 方法2：使用快捷命令
./.claude-hooks/commit

# 方法3：使用npm脚本
npm run claude-commit
```

### 3. 监控服务管理

```bash
# 启动监控服务
npm run claude-watch start --daemon

# 停止监控服务
npm run claude-watch stop

# 查看监控状态
npm run claude-watch status
```

### 4. 自动触发（推荐）

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
