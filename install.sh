#!/usr/bin/env bash
#
# install.sh - Tmux 配置自动部署脚本 (Linux / macOS)
#
# 功能：
#   1. 检测 tmux 是否已安装
#   2. 备份已有的 ~/.tmux.conf
#   3. 创建从仓库 .tmux.conf 到 ~/.tmux.conf 的软链接
#   4. 部署 TokyoNight 主题文件到 ~/.config/tmux/tokyonight/
#
# 用法：
#   chmod +x install.sh && ./install.sh
#

set -euo pipefail

# ─── 颜色输出 ───────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

info()    { printf "${CYAN}[INFO]${NC}    %s\n" "$*"; }
success() { printf "${GREEN}[OK]${NC}      %s\n" "$*"; }
warn()    { printf "${YELLOW}[WARN]${NC}    %s\n" "$*"; }
error()   { printf "${RED}[ERROR]${NC}   %s\n" "$*" >&2; }

# ─── 检测 tmux ──────────────────────────────────────────────
check_tmux() {
    info "检测 tmux 是否已安装..."

    if command -v tmux &>/dev/null; then
        success "tmux $(tmux -V 2>&1)"
        return 0
    fi

    error "未检测到 tmux，请先安装 tmux。"

    # 尝试给出安装建议
    local os
    os="$(uname -s)"
    case "$os" in
        Darwin)
            echo "  macOS 用户请运行:  brew install tmux"
            ;;
        Linux)
            if command -v apt &>/dev/null; then
                echo "  请运行:  sudo apt update && sudo apt install tmux"
            elif command -v dnf &>/dev/null; then
                echo "  请运行:  sudo dnf install tmux"
            elif command -v yum &>/dev/null; then
                echo "  请运行:  sudo yum install tmux"
            elif command -v pacman &>/dev/null; then
                echo "  请运行:  sudo pacman -S tmux"
            else
                echo "  请通过你使用的包管理器安装 tmux。"
            fi
            ;;
    esac

    exit 1
}

# ─── 备份已有配置 ───────────────────────────────────────────
backup_existing_conf() {
    local target="$HOME/.tmux.conf"

    if [ -e "$target" ] || [ -L "$target" ]; then
        local backup="${target}.bak.$(date +%Y%m%d_%H%M%S)"
        info "检测到已有 ~/.tmux.conf，正在备份..."
        if mv "$target" "$backup"; then
            success "已备份至 $backup"
        else
            error "备份失败，安装终止。"
            exit 1
        fi
    else
        info "未检测到已有 ~/.tmux.conf，跳过备份。"
    fi
}

# ─── 创建软链接 ─────────────────────────────────────────────
create_symlink() {
    local src
    src="$(pwd)/.tmux.conf"

    if [ ! -f "$src" ]; then
        error "未找到源配置文件 $src，请确保在仓库根目录下运行此脚本。"
        exit 1
    fi

    local target="$HOME/.tmux.conf"

    info "创建软链接: $target -> $src"
    if ln -s "$src" "$target"; then
        success "软链接创建成功。"
    else
        error "软链接创建失败。"
        exit 1
    fi
}

# ─── 部署主题文件 ───────────────────────────────────────────
deploy_themes() {
    local theme_dir="$HOME/.config/tmux/tokyonight"
    local src_dir
    src_dir="$(pwd)/tmux/tokyonight"

    if [ ! -d "$src_dir" ]; then
        warn "未找到主题目录 $src_dir，跳过主题部署。"
        return 0
    fi

    info "部署 TokyoNight 主题到 $theme_dir ..."
    mkdir -p "$theme_dir"

    local theme_file
    local count=0
    for theme_file in "$src_dir"/*.tmux; do
        if [ -f "$theme_file" ]; then
            cp "$theme_file" "$theme_dir/"
            ((count++))
        fi
    done

    if [ "$count" -gt 0 ]; then
        success "已部署 $count 个主题文件。"
    else
        warn "未找到 .tmux 主题文件，请检查 tmux/tokyonight/ 目录。"
    fi
}

# ─── 验证安装 ───────────────────────────────────────────────
verify_install() {
    info "验证安装..."

    local ok=true

    if [ ! -L "$HOME/.tmux.conf" ]; then
        error "~/.tmux.conf 不是有效的软链接。"
        ok=false
    fi

    if [ ! -d "$HOME/.config/tmux/tokyonight" ]; then
        error "主题目录不存在: ~/.config/tmux/tokyonight"
        ok=false
    fi

    if $ok; then
        success "安装验证通过。"
    else
        error "安装验证失败，请检查上述错误。"
        exit 1
    fi
}

# ─── 安装总结 ───────────────────────────────────────────────
print_summary() {
    echo ""
    echo "=============================================="
    echo "  Tmux 配置安装完成！"
    echo "=============================================="
    echo ""
    echo "  下一步:"
    echo "    1. 启动 tmux:           tmux"
    echo "    2. 重载配置:            prefix + r"
    echo "    3. 切换主题:            编辑 ~/.tmux.conf 中的主题引用行"
    echo ""
    echo "  默认前缀键: Ctrl+a  (原 Ctrl+b 已取消绑定)"
    echo "  查看完整快捷键:  cat $(pwd)/README.md"
    echo ""
}

# ─── 主流程 ─────────────────────────────────────────────────
main() {
    echo ""
    printf "${CYAN}╔══════════════════════════════════════╗${NC}\n"
    printf "${CYAN}║   Tmux Config Installer (Linux/macOS) ║${NC}\n"
    printf "${CYAN}╚══════════════════════════════════════╝${NC}\n"
    echo ""

    check_tmux
    backup_existing_conf
    create_symlink
    deploy_themes
    verify_install
    print_summary
}

main "$@"
