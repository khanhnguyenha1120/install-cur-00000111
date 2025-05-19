#!/usr/bin/env bash
set -euo pipefail

# SCRIPT: cursor_reset.sh
# USAGE: sudo bash cursor_reset.sh

# 1) Các đường dẫn khả dĩ chứa binary 'cursor'
SEARCH_BINS=(
  "/usr/local/bin/cursor"
  "/usr/bin/cursor"
  "$HOME/.local/bin/cursor"
  "/snap/bin/cursor"
)

# 2) Tìm binary
CURSOR_BIN=""
for p in "${SEARCH_BINS[@]}"; do
  if [ -x "$p" ]; then
    CURSOR_BIN="$p"
    break
  fi
done
if [ -z "$CURSOR_BIN" ] && command -v cursor &>/dev/null; then
  CURSOR_BIN="$(command -v cursor)"
fi
if [ -z "$CURSOR_BIN" ]; then
  echo "[ERROR] Không tìm được binary 'cursor'." >&2
  exit 1
fi
echo "[INFO] Sử dụng binary: $CURSOR_BIN"

# 3) Tìm thư mục resources chứa JS
#    Phổ biến: /opt/CursorInstall/resources hoặc cùng cấp với binary
RES_DIR_CANDIDATES=(
  "/opt/CursorInstall/resources"
  "$(dirname "$(dirname "$CURSOR_BIN")")/resources"
  "/usr/local/share/cursor/resources"
  "/usr/share/cursor/resources"
  "$HOME/.local/share/cursor/resources"
)
RES_DIR=""
for d in "${RES_DIR_CANDIDATES[@]}"; do
  if [ -d "$d" ]; then
    RES_DIR="$d"
    break
  fi
done
# nếu chưa tìm, thử scan nhanh:
if [ -z "$RES_DIR" ]; then
  FOUND=$(find /usr /opt "$HOME/.local" -maxdepth 3 -type d -iname resource* 2>/dev/null | head -n1 || true)
  if [ -n "$FOUND" ]; then
    RES_DIR="$FOUND"
  fi
fi
if [ -z "$RES_DIR" ]; then
  echo "[ERROR] Không tìm được thư mục resources của Cursor." >&2
  echo "Hãy đảm bảo bạn đã cài Cursor đầy đủ (ví dụ bằng AppImage giải nén vào /opt/CursorInstall)." >&2
  exit 1
fi
echo "[INFO] Thư mục resources: $RES_DIR"

# 4) Backup
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="${RES_DIR}_backup_$TIMESTAMP"
cp -r "$RES_DIR" "$BACKUP_DIR"
echo "[INFO] Đã backup resources sang: $BACKUP_DIR"

# 5) Sinh UUID mới
if command -v uuidgen &>/dev/null; then
  NEW_UUID=$(uuidgen)
else
  # fallback bằng date+random
  NEW_UUID=$(date +%s%N | sha256sum | head -c32)
fi
echo "[INFO] Device ID mới: $NEW_UUID"

# 6) Patch tất cả .js trong resources: 
#    - Thay deviceId cũ
#    - Comment dòng autoUpdater.checkForUpdates()
grep -Rl "deviceId" "$RES_DIR"/*.js 2>/dev/null | while read js; do
  echo "  ▸ Patching $js"
  # replace deviceId: "xxxx" → deviceId: "NEW_UUID"
  sed -i -E "s/(deviceId|DEVICE_ID)[[:space:]]*[:=][[:space:]]*\"[^\"]*\"/\1: \"$NEW_UUID\"/g" "$js"
  # disable autoUpdater
  sed -i -E "s/([^.]*autoUpdater\.checkForUpdates\(\))/\/\/\1/g" "$js"
done

echo "[SUCCESS] Đã reset Device ID & disable auto-update."
echo "Mở lại Cursor, đăng nhập và kiểm tra xem trial đã reset chưa."
