@echo off
setlocal
set "BASE_DIR=%~dp0"
set "REMOTE_ZIP=https://github.com/aldolomascolo-max/cto-company-installer/raw/main/cto-company-portable.zip"
set "TMP_DIR=%TEMP%\cto-company-install-%RANDOM%"

where py >nul 2>&1
if %errorlevel%==0 (
  set "PY=py -3"
) else (
  where python >nul 2>&1
  if not %errorlevel%==0 (
    echo 未找到 Python 3。请先安装 Python 3，再双击此文件。
    pause
    exit /b 2
  )
  set "PY=python"
)

if exist "%BASE_DIR%install.py" if exist "%BASE_DIR%plugin\" (
  call %PY% "%BASE_DIR%install.py"
  goto finish
)

mkdir "%TMP_DIR%" >nul 2>&1
if exist "%BASE_DIR%cto-company-portable.zip" (
  copy /y "%BASE_DIR%cto-company-portable.zip" "%TMP_DIR%\cto-company-portable.zip" >nul
) else (
  echo 正在下载公开 CTO 安装包……
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -UseBasicParsing '%REMOTE_ZIP%' -OutFile '%TMP_DIR%\cto-company-portable.zip'"
  if not %errorlevel%==0 goto failed
)
powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Force '%TMP_DIR%\cto-company-portable.zip' '%TMP_DIR%\extracted'"
if not exist "%TMP_DIR%\extracted\cto-company-portable\install.py" goto failed
call %PY% "%TMP_DIR%\extracted\cto-company-portable\install.py"
goto finish

:failed
echo 安装包下载或解压失败。
exit /b 2

:finish
echo.
echo 安装命令已完成。请重新打开 Codex，再粘贴 restore-prompt.txt 做自检。
pause
