# Scrutiny

**Native plan editor for Claude Code with side-by-side diffs and inline commenting.**

Review and refine AI-generated plans with a polished editing experience. Built with Tauri and Rust for native performance.

![Screenshot placeholder]

---

## What is Scrutiny?

Scrutiny transforms how you review Claude Code plans. Instead of approving plans in a cramped terminal, you get:

- ✅ **Side-by-side diff view** — Original plan vs your edits
- ✅ **Inline comments** — Click any line to add feedback  
- ✅ **Full editing** — CodeMirror editor with syntax highlighting
- ✅ **Real-time diff** — Changes highlight as you type
- ✅ **Native performance** — Rust backend, ~8MB binary, 200ms startup
- ✅ **Dark theme** — Matches VS Code aesthetic

---

## Installation

### Download Pre-built Binary

**Coming soon:** Download from [Releases](https://github.com/jackmarketon/scrutiny/releases)

- **macOS**: Download `Scrutiny-macos.dmg`
- **Linux**: Download `scrutiny-linux` 
- **Windows**: Download `scrutiny-windows.exe`

### Install Claude Plugin

```bash
# Clone repository
git clone https://github.com/jackmarketon/scrutiny.git
cd scrutiny

# Install plugin
claude plugins add $(pwd)/claude-plugin
```

### Verify

```bash
# Check plugin is installed
claude plugins list | grep scrutiny

# Test the app (macOS example)
open /Applications/Scrutiny.app
```

---

## Usage

### When Claude presents a plan:

Scrutiny launches automatically in a native window.

**Workflow:**

1. **Review side-by-side**
   - Left pane: Original plan (reference)
   - Right pane: Your edits (fully editable)

2. **Make changes** (choose one or both):
   - **Add inline comments:** Click "💬 Add Comment" → Select line → Type feedback
   - **Edit directly:** Click in right pane → Edit like code → See diff highlight

3. **Submit feedback:**
   - **Approve & Send:** Sends your changes + comments to Claude
   - **Cancel:** Closes without saving

### Example

**Original plan:**
```markdown
## Step 1: Update database
## Step 2: Deploy to production
```

**Your edits:**
```markdown
## Step 1: Update database with migration script
## Step 2: Test in staging environment
## Step 3: Deploy to production with feature flag
```

**Comments:**
- Line 1: "Need rollback strategy for migration"
- Line 3: "How long should we test in staging?"

**Claude responds:**
> Thanks for the feedback! I've updated the plan:
> 
> 1. Rollback strategy: Using reversible migrations with `down.sql` scripts
> 2. Staging duration: Recommend 24-48h with production traffic replay
> 
> Does this address your concerns?

---

## Features

| Feature | Description |
|---------|-------------|
| **Side-by-side diff** | Original vs edited, real-time highlighting |
| **Inline comments** | Click any line to add context-specific feedback |
| **Full editing** | CodeMirror 6 editor with markdown syntax highlighting |
| **Native performance** | Rust backend, 200-300ms startup, ~80MB memory |
| **Dark theme** | Matches VS Code aesthetic out of the box |
| **Cross-platform** | macOS, Linux, Windows |

---

## Tech Stack

- **Backend:** Tauri 2.0 (Rust), similar (diff library)
- **Frontend:** React, TypeScript, CodeMirror 6, Vite
- **Bundle size:** ~8MB (vs Electron's 100MB+)
- **Performance:** 200-300ms startup, <10ms diff computation

---

## Troubleshooting

### App doesn't launch from Claude

**Check plugin is installed:**
```bash
claude plugins list | grep scrutiny
```

**Re-install plugin:**
```bash
cd scrutiny
claude plugins add $(pwd)/claude-plugin
```

### Comments not showing up

**Check feedback file exists:**
```bash
ls -la /tmp/claude-plans/*.feedback.json
```

### App crashes on startup

**Enable debug logging:**
```bash
# macOS/Linux
RUST_LOG=debug /path/to/scrutiny /tmp/test.md

# Windows
set RUST_LOG=debug
scrutiny.exe C:\Temp\test.md
```

### Can't find binary

**Download location:**
- **macOS**: Applications folder or Downloads
- **Linux**: `~/Downloads/scrutiny` (make executable: `chmod +x`)
- **Windows**: Downloads folder

---

## Development

Want to build from source or contribute? See **[DEVELOPMENT.md](DEVELOPMENT.md)** for full details.

### Quick: Test Plugin Locally

To test the plugin without installing it globally:

```bash
# Run Claude Code with local plugin directory
claude --plugin-dir ${PWD}/claude-plugin
```

This loads the plugin from your checkout instead of `~/.config/claude/plugins`, useful for testing changes.

### Prerequisites

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
     libssl-dev \
     libgtk-3-dev \
     libayatana-appindicator3-dev \
     librsvg2-dev

   # Fedora
   sudo dnf install webkit2gtk4.1-devel \
     openssl-devel \
     curl \
     wget \
     libappindicator-gtk3-devel \
     librsvg2-devel

   # Arch
   sudo pacman -S webkit2gtk-4.1 \
     base-devel \
     curl \
     wget \
     openssl \
     gtk3 \
     libappindicator-gtk3 \
     librsvg
   ```

### Build from Source

```bash
# Clone repository
git clone https://github.com/jackmarketon/scrutiny.git
cd scrutiny

# Install dependencies
npm install

# Build for production
npm run tauri:build
```

**Build output:**
- **macOS**: `src-tauri/target/release/bundle/macos/Scrutiny.app`
- **Linux**: `src-tauri/target/release/scrutiny`
- **Windows**: `src-tauri/target/release/scrutiny.exe`

### Development Mode

Run with hot-reload:
```bash
npm run tauri:dev
```

This starts:
- Vite dev server on `localhost:1420`
- Tauri app with automatic reload on file changes

### Project Structure

```
scrutiny/
├── src/                    # React frontend
│   ├── App.tsx            # Main UI component
│   ├── main.tsx           # Entry point
│   └── styles.css         # Dark theme
├── src-tauri/             # Rust backend
│   ├── src/
│   │   └── main.rs       # Tauri commands
│   ├── Cargo.toml        # Rust dependencies
│   └── tauri.conf.json   # Tauri configuration
├──          # Claude Code integration
│   └── hooks/
│       ├── hooks.json    # Event bindings
│       └── edit-plan.sh  # Launch script
└── package.json          # npm dependencies
```

### Customize Theme

Edit `src/styles.css`:
```css
:root {
  --bg-primary: #1e1e1e;    /* Main background */
  --accent-blue: #007acc;   /* Primary buttons */
  --text-primary: #cccccc;  /* Main text */
  /* ... */
}
```

### Architecture

```
Claude Code (plan-approval event)
  ↓
Plugin Hook (edit-plan.sh)
  - Writes plan to /tmp/claude-plans/
  - Launches Tauri app
  ↓
Tauri Backend (Rust)
  - load_plan() — Reads plan file
  - compute_diff() — Computes diff with 'similar' crate
  - save_feedback() — Writes feedback JSON
  ↓
React Frontend
  - CodeMirror MergeView
  - Comment UI
  - Approve/Reject flow
```

---

## Roadmap

- [ ] **Keyboard shortcuts** — Cmd+Enter to approve, Esc to cancel
- [ ] **Comment threads** — Multi-line discussions on plans
- [ ] **Export to PR** — Generate PR description from plan
- [ ] **Syntax highlighting** — For code blocks in markdown
- [ ] **Team review** — Multiple people comment on same plan
- [ ] **Git integration** — Compare plan with actual branch changes
- [ ] **Templates** — Common plan patterns for quick start

---

## Performance

| Metric | Value |
|--------|-------|
| **Binary size** | ~8MB (vs Electron: 100MB+) |
| **Startup time** | 200-300ms |
| **Memory usage** | 80-120MB (vs web: 300MB+) |
| **Diff computation** | <10ms for 1000-line files |
| **Editor bundle** | 500KB (CodeMirror vs Monaco: 5MB) |

---

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feat/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feat/amazing-feature`)
5. Open a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

---

## License

MIT © 2026 Jackson Marketon

See [LICENSE](LICENSE) for details.

---

## Support

- **Issues:** https://github.com/jackmarketon/scrutiny/issues
- **Discussions:** https://github.com/jackmarketon/scrutiny/discussions
- **Changelog:** https://github.com/jackmarketon/scrutiny/releases
