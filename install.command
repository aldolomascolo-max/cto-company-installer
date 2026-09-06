#!/bin/bash
# Double-click this file on macOS for a one-click CTO installation.
set -u

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REMOTE_ZIP="https://github.com/aldolomascolo-max/cto-company-installer/raw/main/cto-company-portable.zip"
TMP_DIR=""

finish() {
  printf '\n安装窗口即将关闭；按回车关闭。\n'
  read -r _ || true
}

cleanup() {
  if [ -n "$TMP_DIR" ] && [ -d "$TMP_DIR" ]; then
    rm -rf "$TMP_DIR"
  fi
}
trap cleanup EXIT

main() {
  if ! command -v python3 >/dev/null 2>&1; then
    echo "未找到 Python 3。请先安装 Python 3，再双击此文件。"
    return 2
  fi

  if [ -f "$BASE_DIR/install.py" ] && [ -d "$BASE_DIR/plugin" ]; then
    python3 "$BASE_DIR/install.py"
    return $?
  fi

  if ! command -v curl >/dev/null 2>&1 || ! command -v unzip >/dev/null 2>&1; then
    echo "系统缺少 curl 或 unzip，无法下载并解压安装包。"
    return 2
  fi

  TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/cto-company-install.XXXXXX")"
  ARCHIVE="$TMP_DIR/cto-company-portable.zip"
  EXTRACTED="$TMP_DIR/extracted"

  if [ -f "$BASE_DIR/cto-company-portable.zip" ]; then
    cp "$BASE_DIR/cto-company-portable.zip" "$ARCHIVE"
  else
    echo "正在下载公开 CTO 安装包……"
    curl -fL --retry 3 --connect-timeout 10 "$REMOTE_ZIP" -o "$ARCHIVE" || return 2
  fi

  mkdir -p "$EXTRACTED"
  unzip -q "$ARCHIVE" -d "$EXTRACTED" || return 2
  if [ ! -f "$EXTRACTED/cto-company-portable/install.py" ]; then
    echo "安装包结构不完整，已停止。"
    return 2
  fi
  python3 "$EXTRACTED/cto-company-portable/install.py"
}

status=0
main || status=$?
if [ "$status" -eq 0 ]; then
  echo ""
  echo "安装命令已完成。请完全退出并重新打开 Codex，再粘贴 restore-prompt.txt 做自检。"
else
  echo ""
  echo "安装未完成（退出码 $status）。请把上面的错误信息发给 Codex CTO。"
fi
finish
exit "$status"
