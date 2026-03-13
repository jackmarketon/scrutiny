#!/bin/bash
# Auto-download Scrutiny binary on plugin installation

set -e

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")" && pwd)}"
BIN_DIR="$PLUGIN_ROOT/bin"
GITHUB_REPO="jackmarketon/scrutiny"
VERSION="${SCRUTINY_VERSION:-latest}"

echo "=== Installing Scrutiny Plugin ==="

# Detect platform
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
  Darwin)
    if [ "$ARCH" = "arm64" ]; then
      PLATFORM="macos-aarch64"
      BINARY_NAME="Scrutiny.app"
    else
      PLATFORM="macos-x86_64"
      BINARY_NAME="Scrutiny.app"
    fi
    ;;
  Linux)
    PLATFORM="linux-x64"
    BINARY_NAME="scrutiny"
    ;;
  MINGW*|MSYS*|CYGWIN*)
    PLATFORM="windows-x64"
    BINARY_NAME="scrutiny.exe"
    ;;
  *)
    echo "ERROR: Unsupported platform: $OS"
    exit 1
    ;;
esac

echo "Detected platform: $PLATFORM"

# Get latest release URL
if [ "$VERSION" = "latest" ]; then
  RELEASE_URL="https://api.github.com/repos/$GITHUB_REPO/releases/latest"
  echo "Fetching latest release info..."
  DOWNLOAD_URL=$(curl -sL "$RELEASE_URL" | grep "browser_download_url.*$PLATFORM" | head -1 | cut -d '"' -f 4)
else
  DOWNLOAD_URL="https://github.com/$GITHUB_REPO/releases/download/$VERSION/scrutiny-$PLATFORM"
fi

if [ -z "$DOWNLOAD_URL" ]; then
  echo "ERROR: Could not find release for $PLATFORM"
  echo ""
  echo "Please download manually from:"
  echo "  https://github.com/$GITHUB_REPO/releases"
  exit 1
fi

echo "Download URL: $DOWNLOAD_URL"

# Create bin directory
mkdir -p "$BIN_DIR"

# Download binary
echo "Downloading Scrutiny..."
TEMP_FILE="$BIN_DIR/scrutiny.tmp"

if command -v curl &> /dev/null; then
  curl -L -o "$TEMP_FILE" "$DOWNLOAD_URL"
elif command -v wget &> /dev/null; then
  wget -O "$TEMP_FILE" "$DOWNLOAD_URL"
else
  echo "ERROR: curl or wget required for download"
  exit 1
fi

# Move to final location
if [ "$OS" = "Darwin" ]; then
  # macOS .app bundle
  if [ -d "$BIN_DIR/Scrutiny.app" ]; then
    rm -rf "$BIN_DIR/Scrutiny.app"
  fi
  mv "$TEMP_FILE" "$BIN_DIR/Scrutiny.app"
else
  # Linux/Windows binary
  mv "$TEMP_FILE" "$BIN_DIR/scrutiny"
  chmod +x "$BIN_DIR/scrutiny"
fi

# Verify
if [ "$OS" = "Darwin" ]; then
  BINARY_PATH="$BIN_DIR/Scrutiny.app"
else
  BINARY_PATH="$BIN_DIR/scrutiny"
fi

if [ ! -e "$BINARY_PATH" ]; then
  echo "ERROR: Installation failed - binary not found"
  exit 1
fi

echo ""
echo "✓ Scrutiny installed successfully!"
echo ""
echo "Binary location: $BINARY_PATH"
echo ""
echo "Usage:"
echo "  When Claude presents a plan, Scrutiny will launch automatically."
echo ""
echo "Test manually:"
if [ "$OS" = "Darwin" ]; then
  echo "  open $BINARY_PATH"
else
  echo "  $BINARY_PATH /tmp/test-plan.md"
fi
echo ""
