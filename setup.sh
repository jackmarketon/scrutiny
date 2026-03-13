#!/bin/bash
# One-command setup for scrutiny

set -e

echo "=== Plan Editor (Tauri) Setup ==="
echo ""

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v rustc &> /dev/null; then
    echo "❌ Rust not found. Install from: https://rustup.rs"
    exit 1
fi
echo "✓ Rust: $(rustc --version)"

if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Install from: https://nodejs.org"
    exit 1
fi
echo "✓ Node.js: $(node --version)"

if ! command -v npm &> /dev/null; then
    echo "❌ npm not found"
    exit 1
fi
echo "✓ npm: $(npm --version)"

if ! command -v claude &> /dev/null; then
    echo "⚠️  Claude CLI not found. Install Claude Code first."
fi

echo ""
echo "Installing dependencies..."
npm install

echo ""
echo "Building Tauri app (this may take a few minutes)..."
npm run tauri:build

echo ""
echo "Making hook executable..."
chmod +x claude-plugin/hooks/edit-plan.sh

echo ""
echo "✓ Build complete!"
echo ""
echo "Next steps:"
echo "  1. Install plugin: claude plugins add $(pwd)/claude-plugin"
echo "  2. Test the app: ./src-tauri/target/release/scrutiny /tmp/test.md"
echo ""
echo "Binary location:"
if [ -f "src-tauri/target/release/scrutiny" ]; then
    ls -lh src-tauri/target/release/scrutiny
fi
if [ -d "src-tauri/target/release/bundle/macos" ]; then
    ls -lh src-tauri/target/release/bundle/macos/*.app
fi
