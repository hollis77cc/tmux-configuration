# Tmux Configuration

一套美观、高效的 tmux 终端复用器配置，基于 TokyoNight 配色主题，提供 vim 风格快捷键与现代化终端体验。

## 功能特性

- **快捷键优化**：前缀键由默认的 `Ctrl+b` 改为 `Ctrl+a`，更符合 GNU Screen 用户的习惯
- **Vim 风格窗格导航**：使用 `h/j/k/l` 在窗格间快速移动，`Ctrl+h/j/k/l` 调整窗格大小
- **Vi 模式复制**：`Esc` 进入复制模式，`v` 开始选择，`y` 复制，`p` 粘贴
- **鼠标支持**：支持鼠标点击切换窗格、调整大小
- **TokyoNight 主题**：提供 day / moon / night / storm 四种配色变体（默认使用 moon）
- **状态栏置顶**：状态栏位于顶部，显示会话名、时间、主机名等信息
- **快速重载**：`prefix + r` 即可重新加载配置

## 目录结构

```
.
├── .tmux.conf                 # 主配置文件
├── tmux/
│   └── tokyonight/
│       ├── tokyonight_day.tmux    # TokyoNight Day 主题
│       ├── tokyonight_moon.tmux   # TokyoNight Moon 主题（默认）
│       ├── tokyonight_night.tmux  # TokyoNight Night 主题
│       └── tokyonight_storm.tmux  # TokyoNight Storm 主题
├── install.sh                 # Linux / macOS 安装脚本
├── install.bat                # Windows 安装脚本
└── README.md
```

## 依赖要求

- **tmux** >= 2.4（推荐 3.0 及以上版本）
- 支持 256 色的终端模拟器
- 推荐使用 [Nerd Font](https://www.nerdfonts.com/) 字体以获得最佳视觉体验（状态栏使用了 Powerline 符号）

## 安装指南

### Linux / macOS

#### 1. 安装 tmux

**macOS (Homebrew)**：
```bash
brew install tmux
```

**Ubuntu / Debian**：
```bash
sudo apt update && sudo apt install tmux
```

**CentOS / Fedora**：
```bash
sudo yum install tmux        # CentOS
sudo dnf install tmux        # Fedora
```

**Arch Linux**：
```bash
sudo pacman -S tmux
```

#### 2. 克隆仓库并安装

```bash
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>
chmod +x install.sh
./install.sh
```

安装脚本会自动：
- 检测 tmux 是否已安装
- 备份已有的 `~/.tmux.conf`（如有）
- 创建从仓库 `.tmux.conf` 到 `~/.tmux.conf` 的软链接
- 部署 TokyoNight 主题到 `~/.config/tmux/tokyonight/`

#### 3. 切换主题

编辑 `~/.tmux.conf`，修改第 47 行的主题文件路径：

```tmux
# 可选: tokyonight_day / tokyonight_moon / tokyonight_night / tokyonight_storm
source-file ~/.config/tmux/tokyonight/tokyonight_night.tmux
```

然后按 `prefix + r` 重载配置。

### Windows (WSL / Git Bash)

#### 通过 WSL 安装

WSL 环境下与 Linux 完全一致，推荐使用 WSL 2 + Windows Terminal。

1. 在 WSL 中安装 tmux：
```bash
sudo apt update && sudo apt install tmux
```

2. 克隆并运行安装脚本：
```bash
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>
chmod +x install.sh
./install.sh
```

#### 通过 Git Bash 安装

1. 确保已安装 [Git for Windows](https://git-scm.com/download/win)（自带 Git Bash）
2. 从 [tmux for Windows](https://github.com/microsoft/terminal) 或 MSYS2 获取 tmux
3. 运行 `install.bat`：

```cmd
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>
install.bat
```

安装脚本会自动：
- 检测 Git Bash 或 WSL 环境
- 备份已有的配置文件（如有）
- 将 `.tmux.conf` 复制到用户主目录
- 部署 TokyoNight 主题文件

#### 手动安装

如果自动脚本不适用，也可以手动完成：

```bash
# 备份旧配置
[ -f ~/.tmux.conf ] && cp ~/.tmux.conf ~/.tmux.conf.bak

# 复制配置
cp .tmux.conf ~/.tmux.conf

# 部署主题
mkdir -p ~/.config/tmux/tokyonight
cp tmux/tokyonight/*.tmux ~/.config/tmux/tokyonight/
```

## 快捷键速查

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+a` | 前缀键（替代默认的 `Ctrl+b`） |
| `prefix + r` | 重载配置文件 |
| `prefix + h/j/k/l` | 在窗格间移动（左/下/上/右） |
| `prefix + Ctrl+h/j/k/l` | 调整窗格大小 |
| `prefix + -` | 水平分割窗格 |
| `prefix + =` | 垂直分割窗格 |
| `prefix + b` | 切换到上一个窗口 |
| `prefix + p` | 粘贴文本 |
| `Esc` | 进入复制模式 |
| `v`（复制模式） | 开始选择文本 |
| `y`（复制模式） | 复制选中文本并退出 |

## 常见问题

### 颜色显示异常

确保终端模拟器支持 256 色，并在配置文件或终端设置中启用。如果使用 tmux 外部终端，可添加：

```bash
export TERM="xterm-256color"
```

### 图标显示异常

如果图标显示异常，可以在 `.bashrc` 文件中添加下面的代码：

```bash
export LANG=en_US.UTF-8
```

### 状态栏符号显示为乱码

这是因为终端缺少 Powerline 字体支持。建议安装 [Nerd Font](https://www.nerdfonts.com/)（如 FiraCode Nerd Font 或 JetBrains Mono Nerd Font），并在终端设置中选用该字体。

### prefix + r 无响应

检查 `~/.tmux.conf` 是否正确链接。可以手动执行：

```bash
tmux source-file ~/.tmux.conf
```

## License

MIT
