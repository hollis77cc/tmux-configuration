@echo off
setlocal enabledelayedexpansion

REM ============================================================
REM  install.bat - Tmux 配置自动部署脚本 (Windows)
REM
REM  功能：
REM    1. 检测 Git Bash / WSL 运行环境
REM    2. 备份已有的 ~/.tmux.conf
REM    3. 复制 .tmux.conf 到用户主目录
REM    4. 部署 TokyoNight 主题文件到 ~/.config/tmux/tokyonight/
REM
REM  用法：
REM    install.bat
REM ============================================================

echo.
echo ╔══════════════════════════════════════╗
echo ║   Tmux Config Installer (Windows)   ║
echo ╚══════════════════════════════════════╝
echo.

REM ─── 定位用户主目录 ──────────────────────────────────────
set "USER_HOME=%USERPROFILE%"
if "%USER_HOME%"=="" (
    echo [ERROR] 无法获取用户主目录路径。
    exit /b 1
)

echo [INFO] 用户主目录: %USER_HOME%

REM ─── 检测运行环境 ────────────────────────────────────────
set "ENV_TYPE=unknown"

REM 检测是否在 Git Bash 中运行 (MSYSTEM 环境变量)
if defined MSYSTEM (
    set "ENV_TYPE=gitbash"
    echo [INFO] 检测到 Git Bash 环境 (MSYSTEM=!MSYSTEM!)
)

REM 检测是否在 WSL 中运行
if not defined ENV_TYPE (
    wsl --status >nul 2>&1
    if !errorlevel! equ 0 (
        set "ENV_TYPE=wsl_detected"
        echo [WARN] 检测到 WSL 可用。推荐直接在 WSL 内运行 install.sh，而非使用本脚本。
        echo [WARN] 继续使用本脚本将采用文件复制模式（非软链接）。
    )
)

if "!ENV_TYPE!"=="unknown" (
    echo [INFO] 运行环境: Windows CMD
)

REM ─── 定位仓库根目录 ──────────────────────────────────────
set "REPO_ROOT=%~dp0"
REM 去除末尾反斜杠
if "!REPO_ROOT:~-1!"=="\" set "REPO_ROOT=!REPO_ROOT:~0,-1!"
echo [INFO] 仓库路径: !REPO_ROOT!

REM 检查 .tmux.conf 是否存在
if not exist "!REPO_ROOT!\.tmux.conf" (
    echo [ERROR] 未找到源配置文件 "!REPO_ROOT!\.tmux.conf"
    echo [ERROR] 请确保在仓库根目录下运行此脚本。
    exit /b 1
)

REM ─── 备份已有配置 ────────────────────────────────────────
set "TARGET_CONF=%USER_HOME%\.tmux.conf"

if exist "!TARGET_CONF!" (
    REM 生成带时间戳的备份文件名
    for /f "tokens=1-6 delims=/-:. " %%a in ('echo %date%_%time%') do (
        set "TIMESTAMP=%%a%%b%%c_%%d%%e%%f"
    )
    REM 剔除时间戳中的空格
    set "TIMESTAMP=!TIMESTAMP: =0!"
    set "BACKUP_CONF=!TARGET_CONF!.bak.!TIMESTAMP!"

    echo [INFO] 检测到已有配置文件，正在备份...
    move "!TARGET_CONF!" "!BACKUP_CONF!" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [OK]   已备份至 !BACKUP_CONF!
    ) else (
        echo [ERROR] 备份失败，安装终止。
        exit /b 1
    )
) else (
    echo [INFO] 未检测到已有配置文件，跳过备份。
)

REM ─── 复制配置文件 ────────────────────────────────────────
echo [INFO] 复制配置文件到 !TARGET_CONF! ...
copy /Y "!REPO_ROOT!\.tmux.conf" "!TARGET_CONF!" >nul 2>&1
if !errorlevel! equ 0 (
    echo [OK]   配置文件复制成功。
) else (
    echo [ERROR] 配置文件复制失败。
    exit /b 1
)

REM ─── 部署主题文件 ────────────────────────────────────────
set "THEME_SRC=!REPO_ROOT!\tmux\tokyonight"
set "THEME_DEST=%USER_HOME%\.config\tmux\tokyonight"

if not exist "!THEME_SRC!" (
    echo [WARN] 未找到主题目录 "!THEME_SRC!"，跳过主题部署。
) else (
    echo [INFO] 部署 TokyoNight 主题到 !THEME_DEST! ...

    REM 创建目标目录
    mkdir "!THEME_DEST!" >nul 2>&1
    if !errorlevel! neq 0 (
        echo [ERROR] 无法创建主题目录 "!THEME_DEST!"。
        exit /b 1
    )

    set "count=0"
    for %%f in ("!THEME_SRC!\*.tmux") do (
        copy /Y "%%f" "!THEME_DEST!\" >nul 2>&1
        if !errorlevel! equ 0 set /a count+=1
    )

    if !count! gtr 0 (
        echo [OK]   已部署 !count! 个主题文件。
    ) else (
        echo [WARN] 未找到 .tmux 主题文件。
    )
)

REM ─── 验证安装 ────────────────────────────────────────────
echo [INFO] 验证安装...

set "OK=true"

if not exist "!TARGET_CONF!" (
    echo [ERROR] 配置文件未成功安装到 !TARGET_CONF!
    set "OK=false"
)

if not exist "!THEME_DEST!" (
    echo [ERROR] 主题目录不存在: !THEME_DEST!
    set "OK=false"
)

if "!OK!"=="true" (
    echo [OK]   安装验证通过。
) else (
    echo [ERROR] 安装验证失败，请检查上述错误。
    exit /b 1
)

REM ─── 安装总结 ────────────────────────────────────────────
echo.
echo ==============================================
echo   Tmux 配置安装完成！
echo ==============================================
echo.
echo   下一步:
echo     1. 启动 tmux:           tmux
echo     2. 重载配置:             prefix + r
echo     3. 切换主题:             编辑 ~/.tmux.conf 中的主题引用行
echo.
echo   默认前缀键: Ctrl+a  (原 Ctrl+b 已取消绑定)
echo   查看完整快捷键:  type README.md
echo.

REM ─── WSL 额外提示 ────────────────────────────────────────
if "!ENV_TYPE!"=="wsl_detected" (
    echo [TIP] 本机已安装 WSL，推荐在 WSL 终端中运行 Linux 版 install.sh
    echo       以获得完整的软链接支持。在 WSL 中执行：
    echo         wsl
    echo         cd !REPO_ROOT!
    echo         bash install.sh
    echo.
)

endlocal
exit /b 0
