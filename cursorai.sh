#!/bin/bash


# Cập nhật hệ thống
echo "Cập nhật hệ thống..."
apt update && apt upgrade -y

# Cài đặt các gói cần thiết
echo "Cài đặt wget và gpg..."
apt install wget gpg -y

sudo apt update && sudo apt install libfuse2

# Script to install Cursor on Ubuntu
# https://www.cursor.com/

echo "Installing Cursor on Ubuntu..."

# Create a directory for downloads if it doesn't exist
mkdir -p ~/Downloads
cd ~/Downloads

# Download specific version of Cursor AppImage
echo "Downloading Cursor version 0.49.6..."

# Use the provided direct download link
CURSOR_URL="https://downloads.cursor.com/production/0781e811de386a0c5bcb07ceb259df8ff8246a52/linux/x64/Cursor-0.49.6-x86_64.AppImage"

echo "Downloading from: $CURSOR_URL"
wget -O Cursor.AppImage "$CURSOR_URL" || curl -L -o Cursor.AppImage "$CURSOR_URL"

# Verify the file was downloaded successfully
if [ ! -f "./Cursor.AppImage" ] || [ ! -s "./Cursor.AppImage" ]; then
    echo "Error: Download failed. Please check your internet connection and try again."
    exit 1
fi

echo "Download completed successfully!"

# Make the AppImage executable
chmod +x Cursor.AppImage

# Create application directory
mkdir -p ~/.local/share/applications
mkdir -p ~/.local/share/icons

# Create desktop entry
cat > ~/.local/share/applications/cursor.desktop << EOF
[Desktop Entry]
Name=Cursor
Comment=AI-first code editor
Exec=${HOME}/Downloads/Cursor.AppImage
Icon=${HOME}/.local/share/icons/cursor.png
Terminal=false
Type=Application
Categories=Development;IDE;
EOF

# Download icon
echo "Downloading Cursor icon..."
wget -O ~/.local/share/icons/cursor.png "https://raw.githubusercontent.com/getcursor/cursor/main/resources/app/resources/cursor_logo.png" || \
curl -L -o ~/.local/share/icons/cursor.png "https://raw.githubusercontent.com/getcursor/cursor/main/resources/app/resources/cursor_logo.png"

# Create symbolic link to make it available system-wide (optional)
mkdir -p ~/.local/bin
ln -sf ~/Downloads/Cursor.AppImage ~/.local/bin/cursor

# Add ~/.local/bin to PATH if not already there
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    echo "Added ~/.local/bin to your PATH in ~/.bashrc"
    echo "Please run 'source ~/.bashrc' after installation to update your PATH"
fi

echo "Installation complete!"
echo "You can start Cursor by:"
echo "  1. Running 'cursor' in the terminal"
echo "  2. Running '~/Downloads/Cursor.AppImage'"
echo "  3. Using the application launcher (may need to log out and back in first)"
