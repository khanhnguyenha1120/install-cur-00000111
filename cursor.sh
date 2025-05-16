#!/bin/bash

# Kiểm tra quyền root
if [[ $EUID -ne 0 ]]; then
   echo "Vui lòng chạy script với quyền root: sudo ./install_cursor.sh"
   exit 1
fi

# Cập nhật hệ thống
echo "Cập nhật hệ thống..."
apt update && apt upgrade -y

# Cài đặt các gói cần thiết
echo "Cài đặt wget và gpg..."
apt install wget gpg -y

# Tải gói .deb mới nhất của Cursor
echo "Tải Cursor từ trang chính thức..."
wget -O cursor.deb https://download.cursor.sh/linux

# Cài đặt Cursor
echo "Cài đặt Cursor..."
apt install ./cursor.deb -y

# Kiểm tra cài đặt
if command -v cursor &> /dev/null; then
    echo "✅ Cursor đã được cài đặt thành công!"
else
    echo "❌ Cài đặt Cursor thất bại."
fi

