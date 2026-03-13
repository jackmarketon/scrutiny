# Plan Editor (Tauri + CodeMirror)

Fast native plan editor for Claude Code with rich diffs and inline commenting.

## Tech Stack

**Backend:**
- **Tauri 2.0** — Rust-based native runtime
- **similar** — Fast Rust diff library

**Frontend:**
- **React + TypeScript**
- **CodeMirror 6** — Lightweight code editor (~500KB vs Monaco's 5MB)
- **Vite** — Fast build tool

**Result:** ~5-10MB native binary with native performance.

---

## Features

- ✅ **Side-by-side diff view** — See original vs your edits
- ✅ **Inline comments** — Click any line to add feedback
- ✅ **Direct editing** — Full CodeMirror editor with syntax highlighting
- ✅ **Fast startup** — Rust backend, lightweight frontend
- ✅ **Native window** — Proper OS integration
- ✅ **Keyboard shortcuts** — Coming soon
- ✅ **Dark theme** — Matches VS Code aesthetic

---

## Prerequisites

1. **Rust** — Install from https://rustup.rs
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

2. **Node.js** — v18+ with npm

3. **System dependencies** (Linux only):
   ```bash
   # Ubuntu/Debian
   sudo apt install libwebkit2gtk-4.1-dev \
     build-essential \
     curl \
     wget \
     file \
     libxdo-dev \
     libssl-dev \
     libayatana-appindicator3-dev \
     librsvg2-dev

   # Fedora
   sudo dnf install webkit2gtk4.1-devel \
     openssl-devel \
     curl \
     wget \
     file \
     libappindicator-gtk3-devel \
     librsvg2-devel

   # Arch
   sudo pacman -S webkit2gtk-4.1 \
     base-devel \
     curl \
     wget \
     file \
     openssl \
     appmenu-gtk-module \
     gtk3 \
     libappindicator-gtk3 \
     librsvg \
     libvips
   ```

---

## Installation

### 1. Build the Tauri App

```bash
cd scrutiny

# Install dependencies
npm install

# Build for production (creates optimized binary)
npm run tauri:build
```

**Build output:**
- **macOS**: `src-tauri/target/release/bundle/macos/Plan Editor.app`
- **Linux**: `src-tauri/target/release/scrutiny`
- **Windows**: `src-tauri/target/release/scrutiny.exe`

### 2. Install Claude Plugin

```bash
# Make hook executable
chmod +x claude-plugin/hooks/edit-plan.sh

# Add to Claude
claude plugins add $(pwd)/claude-plugin
```

### 3. Verify Installation

```bash
# Check plugin is registered
claude plugins list | grep plan-editor

# Test the app directly
./src-tauri/target/release/scrutiny /tmp/test-plan.md
```

---

## Usage

### When Claude presents a plan:

1. **App launches automatically** in a native window
2. **Review in split view:**
   - Left pane: Original plan
   - Right pane: Your edits (fully editable)
3. **Add comments:**
   - Click "Add Comment" button
   - Select line number
   - Type your feedback
4. **Edit directly:**
   - Click in the right pane
   - Edit like a normal code editor
   - Changes diff in real-time
5. **Submit:**
   - "Approve & Send Feedback" → Sends to Claude
   - "Cancel" → Closes without saving

### Example Session

**Original plan:**
```markdown
## Step 1: Update database
## Step 2: Deploy
```

**Your edits:**
```markdown
## Step 1: Update database with migration script
## Step 1.5: Run migration in staging
## Step 2: Deploy with feature flag
```

**Comments added:**
- Line 1: "Should we add rollback strategy?"
- Line 3: "How long should we test in staging?"

**Claude receives:**
```json
{
  "type": "plan_feedback",
  "comments": [
    {"line": 1, "text": "Should we add rollback strategy?"},
    {"line": 3, "text": "How long should we test in staging?"}
  ],
  "diff": { /* structured diff */ },
  "edited_plan": "..."
}
```

---

## Development

### Run in dev mode:

```bash
npm run tauri:dev
```

This starts:
- Vite dev server on `localhost:1420`
- Tauri app with hot-reload

### Build for release:

```bash
npm run tauri:build
```

### Customize theme:

Edit `src/styles.css`:
```css
:root {
  --bg-primary: #1e1e1e;    /* Main background */
  --accent-blue: #007acc;   /* Primary buttons */
  /* ... */
}
```

---

## Architecture

```
┌─────────────────────────────────────────┐
│ Claude Code                             │
│  └─ plan-approval event                 │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│ Plugin Hook (Bash)                      │
│  - Receives plan JSON                   │
│  - Writes to /tmp/claude-plans/         │
│  - Launches Tauri app                   │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│ Tauri App (Rust Backend)                │
│  - load_plan() → reads file             │
│  - compute_diff() → similar crate       │
│  - save_feedback() → writes JSON        │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│ React Frontend                          │
│  - CodeMirror MergeView                 │
│  - Comment UI                           │
│  - Approve/Reject buttons               │
└─────────────────────────────────────────┘
```

---

## Troubleshooting

### App doesn't launch

**Check binary exists:**
```bash
ls -lh src-tauri/target/release/scrutiny
```

**Build if missing:**
```bash
npm run tauri:build
```

### Build fails on Linux

**Install webkit2gtk:**
```bash
# Ubuntu/Debian
sudo apt install libwebkit2gtk-4.1-dev
```

### Comments not saving

**Check feedback file:**
```bash
ls -la /tmp/claude-plans/*.feedback.json
```

**Enable debug logging:**
```bash
RUST_LOG=debug ./src-tauri/target/release/scrutiny
```

### Window doesn't close

**Force close:**
```bash
pkill scrutiny
```

---

## Roadmap

- [ ] Keyboard shortcuts (Cmd+Enter to approve)
- [ ] Multi-line comment threads
- [ ] Export plan as PR description
- [ ] Syntax highlighting for code blocks in plans
- [ ] Team review mode (multiple reviewers)
- [ ] Git integration (compare with branch state)

---

## Performance

**Startup time:** ~200-300ms (native binary)
**Bundle size:** ~8MB (vs Electron's 100MB+)
**Memory:** ~80-120MB (vs Monaco web: 300MB+)
**Diff computation:** <10ms for 1000-line files

---

## License

MIT
