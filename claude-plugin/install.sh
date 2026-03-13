#!/bin/bash
# Auto-download Scrutiny binary on plugin installation

set -e

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
BIN_DIR="$PLUGIN_ROOT/bin"
GITHUB_REPO="jackmarketon/scrutiny"
VERSION="${SCRUTINY_VERSION:-latest}"
VERSION_FILE="$BIN_DIR/.version"

echo "=== Installing Scrutiny Plugin ==="

# Check if already installed and up to date
if [ -f "$VERSION_FILE" ] && [ "$VERSION" = "latest" ]; then
  INSTALLED_VERSION=$(cat "$VERSION_FILE")
  LATEST_VERSION=$(curl -sL "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | grep '"tag_name"' | cut -d '"' -f 4)
  
  if [ "$INSTALLED_VERSION" = "$LATEST_VERSION" ]; then
    echo "✓ Already up to date ($INSTALLED_VERSION)"
    exit 0
  else
    echo "Update available: $INSTALLED_VERSION → $LATEST_VERSION"
  fi
fi

# Detect platform
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
  Darwin)
    if [ "$ARCH" = "arm64" ]; then
      TARGET="aarch64-apple-darwin"
      PLATFORM="macos-aarch64"
      ASSET_NAME="Scrutiny-aarch64-apple-darwin.zip"
      BINARY_NAME="Scrutiny.app"
    else
      TARGET="x86_64-apple-darwin"
      PLATFORM="macos-x86_64"
      ASSET_NAME="Scrutiny-x86_64-apple-darwin.zip"
      BINARY_NAME="Scrutiny.app"
    fi
    ;;
  Linux)
    TARGET="x86_64-unknown-linux-gnu"
    PLATFORM="linux-x64"
    ASSET_NAME="scrutiny"
    BINARY_NAME="scrutiny"
    ;;
  MINGW*|MSYS*|CYGWIN*)
    TARGET="x86_64-pc-windows-msvc"
    PLATFORM="windows-x64"
    ASSET_NAME="scrutiny.exe"
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
  RELEASE_INFO=$(curl -sL "$RELEASE_URL")
  RELEASE_TAG=$(echo "$RELEASE_INFO" | grep '"tag_name"' | head -1 | cut -d '"' -f 4)
  DOWNLOAD_URL=$(echo "$RELEASE_INFO" | grep "browser_download_url.*$ASSET_NAME" | head -1 | cut -d '"' -f 4)
else
  RELEASE_TAG="$VERSION"
  DOWNLOAD_URL="https://github.com/$GITHUB_REPO/releases/download/$VERSION/$ASSET_NAME"
fi

if [ -z "$DOWNLOAD_URL" ]; then
  echo "ERROR: Could not find release asset: $ASSET_NAME"
  echo ""
  echo "Please download manually from:"
  echo "  https://github.com/$GITHUB_REPO/releases"
  exit 1
fi

echo "Release: $RELEASE_TAG"
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

# Install binary
if [ "$OS" = "Darwin" ]; then
  # macOS: unzip .app bundle
  echo "Extracting macOS app bundle..."
  if [ -d "$BIN_DIR/Scrutiny.app" ]; then
    rm -rf "$BIN_DIR/Scrutiny.app"
  fi
  unzip -q "$TEMP_FILE" -d "$BIN_DIR"
  rm "$TEMP_FILE"
  chmod +x "$BIN_DIR/Scrutiny.app/Contents/MacOS/Scrutiny"
else
  # Linux/Windows: direct binary
  mv "$TEMP_FILE" "$BIN_DIR/$BINARY_NAME"
  chmod +x "$BIN_DIR/$BINARY_NAME"
fi

# Save installed version
echo "$RELEASE_TAG" > "$VERSION_FILE"

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
