# Quick Start

## 1. Prerequisites

Install Rust (if not already):
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

## 2. Build & Install

```bash
cd scrutiny

# One command setup
chmod +x setup.sh
./setup.sh
```

This will:
- ✓ Check prerequisites (Rust, Node.js, npm)
- ✓ Install npm dependencies
- ✓ Build Tauri app (~2-5 minutes first time)
- ✓ Make plugin hook executable

## 3. Install Plugin

```bash
claude plugins add $(pwd)/claude-plugin
```

Verify:
```bash
claude plugins list | grep plan-editor
```

## 4. Test It

### Manual test:
```bash
# Create test plan
echo "## Step 1: Test
## Step 2: Deploy" > /tmp/test.md

# Launch app
./src-tauri/target/release/scrutiny /tmp/test.md
```

### With Claude:
1. Start Claude session
2. Ask for a multi-step plan
3. When Claude asks for approval, the app launches automatically
4. Make edits, add comments
5. Click "Approve & Send Feedback"
6. See Claude's response to your feedback

## What You'll See

```
┌─────────────────────────────────────────┐
│ Claude Plan Review                      │
├─────────────────────────────────────────┤
│ Original Plan    │  Your Changes        │
│                 │                       │
│ ## Step 1       │ ## Step 1            │
│ Deploy          │ Test in staging      │
│                 │                       │
│                 │ ## Step 2            │
│                 │ Deploy to prod       │
│                 │                       │
├─────────────────────────────────────────┤
│ 💬 Add Comment (Line 1)                 │
├─────────────────────────────────────────┤
│ Comments (1):                           │
│ • Line 1: "Need rollback plan"          │
├─────────────────────────────────────────┤
│        ✓ Approve      ✗ Cancel         │
└─────────────────────────────────────────┘
```

## Platform-Specific Notes

### macOS
Binary location: `src-tauri/target/release/bundle/macos/Plan Editor.app`

### Linux
Binary location: `src-tauri/target/release/scrutiny`

**Debian/Ubuntu dependencies:**
```bash
sudo apt install libwebkit2gtk-4.1-dev \
  build-essential \
  curl \
  wget \
  libssl-dev
```

### Windows
Binary location: `src-tauri\target\release\scrutiny.exe`

Requires: Microsoft Edge WebView2 (usually pre-installed on Windows 10+)

## Troubleshooting

**Build fails:**
```bash
# Update Rust
rustup update stable

# Clean and rebuild
cd src-tauri
cargo clean
cd ..
npm run tauri:build
```

**App doesn't launch from Claude:**
```bash
# Check hook is executable
ls -la claude-plugin/hooks/edit-plan.sh

# Test hook manually
echo '{"id":"test","plan_text":"## Test"}' | bash claude-plugin/hooks/edit-plan.sh
```

**"webkit2gtk not found" (Linux):**
```bash
# Ubuntu/Debian
sudo apt install libwebkit2gtk-4.1-dev

# Fedora
sudo dnf install webkit2gtk4.1-devel

# Arch
sudo pacman -S webkit2gtk-4.1
```

## Next Steps

See [README.md](README.md) for:
- Full feature list
- Architecture details
- Development workflow
- Customization options
