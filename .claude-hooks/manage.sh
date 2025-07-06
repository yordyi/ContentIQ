#!/bin/bash

# Claude Code Hooks 管理脚本
# 提供统一的管理界面

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 显示横幅
show_banner() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                   Claude Code Hooks 管理器                  ║"
    echo "║                    自动提交系统控制面板                      ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# 显示状态
show_status() {
    echo -e "${BLUE}📊 系统状态${NC}"
    echo "----------------------------------------"
    
    # 检查监控状态
    if [ -f "$PROJECT_ROOT/.claude-hooks/watch.pid" ]; then
        local pid=$(cat "$PROJECT_ROOT/.claude-hooks/watch.pid")
        if kill -0 "$pid" 2>/dev/null; then
            echo -e "监控服务: ${GREEN}✅ 运行中 (PID: $pid)${NC}"
        else
            echo -e "监控服务: ${RED}❌ 已停止${NC}"
        fi
    else
        echo -e "监控服务: ${YELLOW}⚠️ 未启动${NC}"
    fi
    
    # 检查配置
    if [ -f "$PROJECT_ROOT/.claude-hooks/config" ]; then
        echo -e "配置文件: ${GREEN}✅ 已配置${NC}"
    else
        echo -e "配置文件: ${YELLOW}⚠️ 使用默认配置${NC}"
    fi
    
    # 检查Git状态
    cd "$PROJECT_ROOT" || exit 1
    if git diff --quiet && git diff --cached --quiet; then
        echo -e "Git状态:  ${GREEN}✅ 无未提交变更${NC}"
    else
        local files=$(git diff --name-only | wc -l | tr -d ' ')
        local staged=$(git diff --cached --name-only | wc -l | tr -d ' ')
        echo -e "Git状态:  ${YELLOW}⚠️ $files个文件已修改, $staged个文件已暂存${NC}"
    fi
    
    # 检查日志文件大小
    if [ -f "$PROJECT_ROOT/.claude-hooks/auto-commit.log" ]; then
        local log_size=$(wc -c < "$PROJECT_ROOT/.claude-hooks/auto-commit.log")
        local log_size_mb=$((log_size / 1024 / 1024))
        if [ $log_size_mb -gt 10 ]; then
            echo -e "日志文件: ${YELLOW}⚠️ ${log_size_mb}MB (建议清理)${NC}"
        else
            echo -e "日志文件: ${GREEN}✅ ${log_size_mb}MB${NC}"
        fi
    fi
    
    echo ""
}

# 显示菜单
show_menu() {
    echo -e "${CYAN}🎛️ 可用操作${NC}"
    echo "----------------------------------------"
    echo "1. 启动监控服务"
    echo "2. 停止监控服务"
    echo "3. 重启监控服务"
    echo "4. 查看监控状态"
    echo "5. 手动执行提交"
    echo "6. 查看最近日志"
    echo "7. 编辑配置文件"
    echo "8. 清理日志文件"
    echo "9. 卸载hooks系统"
    echo "0. 退出"
    echo ""
}

# 启动监控
start_monitoring() {
    echo -e "${BLUE}🚀 启动监控服务...${NC}"
    "$PROJECT_ROOT/.claude-hooks/watch-claude.sh" start --daemon
    sleep 2
    "$PROJECT_ROOT/.claude-hooks/watch-claude.sh" status
}

# 停止监控
stop_monitoring() {
    echo -e "${BLUE}🛑 停止监控服务...${NC}"
    "$PROJECT_ROOT/.claude-hooks/watch-claude.sh" stop
}

# 重启监控
restart_monitoring() {
    echo -e "${BLUE}🔄 重启监控服务...${NC}"
    "$PROJECT_ROOT/.claude-hooks/watch-claude.sh" restart
    sleep 2
    "$PROJECT_ROOT/.claude-hooks/watch-claude.sh" status
}

# 查看监控状态
check_status() {
    "$PROJECT_ROOT/.claude-hooks/watch-claude.sh" status
}

# 手动提交
manual_commit() {
    echo -e "${BLUE}📝 执行手动提交...${NC}"
    "$PROJECT_ROOT/.claude-hooks/auto-commit.sh"
}

# 查看日志
view_logs() {
    echo -e "${BLUE}📋 最近的日志记录:${NC}"
    echo "----------------------------------------"
    if [ -f "$PROJECT_ROOT/.claude-hooks/auto-commit.log" ]; then
        tail -20 "$PROJECT_ROOT/.claude-hooks/auto-commit.log"
    else
        echo "暂无日志记录"
    fi
    echo ""
    
    if [ -f "$PROJECT_ROOT/.claude-hooks/watch.log" ]; then
        echo -e "${BLUE}📋 监控日志:${NC}"
        echo "----------------------------------------"
        tail -10 "$PROJECT_ROOT/.claude-hooks/watch.log"
    fi
}

# 编辑配置
edit_config() {
    local config_file="$PROJECT_ROOT/.claude-hooks/config"
    
    if [ -f "$config_file" ]; then
        echo -e "${BLUE}⚙️ 编辑配置文件...${NC}"
        "${EDITOR:-nano}" "$config_file"
    else
        echo -e "${YELLOW}⚠️ 配置文件不存在，是否创建默认配置？ (y/n)${NC}"
        read -r create_config
        if [ "$create_config" = "y" ] || [ "$create_config" = "Y" ]; then
            # 创建默认配置文件（这里会从之前创建的配置文件复制）
            echo -e "${GREEN}✅ 已创建默认配置文件${NC}"
            "${EDITOR:-nano}" "$config_file"
        fi
    fi
}

# 清理日志
clean_logs() {
    echo -e "${BLUE}🧹 清理日志文件...${NC}"
    
    if [ -f "$PROJECT_ROOT/.claude-hooks/auto-commit.log" ]; then
        > "$PROJECT_ROOT/.claude-hooks/auto-commit.log"
        echo -e "${GREEN}✅ 已清理提交日志${NC}"
    fi
    
    if [ -f "$PROJECT_ROOT/.claude-hooks/watch.log" ]; then
        > "$PROJECT_ROOT/.claude-hooks/watch.log"
        echo -e "${GREEN}✅ 已清理监控日志${NC}"
    fi
}

# 卸载系统
uninstall_hooks() {
    echo -e "${RED}⚠️ 确定要卸载Claude Code Hooks系统吗？ (y/n)${NC}"
    read -r confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        echo -e "${BLUE}🗑️ 正在卸载...${NC}"
        
        # 停止监控
        "$PROJECT_ROOT/.claude-hooks/watch-claude.sh" stop 2>/dev/null
        
        # 删除hooks目录
        rm -rf "$PROJECT_ROOT/.claude-hooks"
        
        # 从package.json中移除脚本
        if [ -f "$PROJECT_ROOT/package.json" ]; then
            node -e "
            const fs = require('fs');
            const path = '$PROJECT_ROOT/package.json';
            const pkg = JSON.parse(fs.readFileSync(path, 'utf8'));
            delete pkg.scripts['claude-commit'];
            delete pkg.scripts['claude-setup'];
            fs.writeFileSync(path, JSON.stringify(pkg, null, 2) + '\n');
            " 2>/dev/null
        fi
        
        echo -e "${GREEN}✅ 卸载完成${NC}"
        exit 0
    else
        echo -e "${YELLOW}取消卸载${NC}"
    fi
}

# 主循环
main() {
    while true; do
        clear
        show_banner
        show_status
        show_menu
        
        echo -n "请选择操作 (0-9): "
        read -r choice
        
        case $choice in
            1) start_monitoring ;;
            2) stop_monitoring ;;
            3) restart_monitoring ;;
            4) check_status ;;
            5) manual_commit ;;
            6) view_logs ;;
            7) edit_config ;;
            8) clean_logs ;;
            9) uninstall_hooks ;;
            0) 
                echo -e "${GREEN}👋 再见！${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ 无效选择，请重试${NC}"
                ;;
        esac
        
        echo ""
        echo -e "${YELLOW}按任意键继续...${NC}"
        read -r
    done
}

# 执行主函数
main "$@" 