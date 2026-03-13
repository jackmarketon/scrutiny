# Development Guide

## Local Plugin Testing

To test the Scrutiny plugin locally without installing it globally, use Claude Code's `--plugin-dir` flag:

### From the Repository Root

```bash
# Run Claude Code with the local plugin directory
claude --plugin-dir ${PWD}/claude-plugin

# Or using relative path
claude --plugin-dir ./claude-plugin
```

### What This Does

- Loads the plugin from your local checkout instead of `~/.config/claude/plugins`
- Lets you test changes to hooks and scripts without reinstalling
- Useful for development and debugging

### Prerequisites

Before testing locally, you need to have built the Scrutiny binary:

```bash
# Build the Tauri app
npm install
cd src-tauri
cargo build --release

# Copy the binary to the plugin directory
mkdir -p ../claude-plugin/bin
cp target/release/scrutiny ../claude-plugin/bin/
```

### Testing Workflow

1. **Make changes** to plugin hooks, install script, etc.
2. **Rebuild** if you changed Rust/frontend code
3. **Run Claude** with `--plugin-dir` flag
4. **Test** the plan review workflow
5. **Iterate** until satisfied

### Debugging

To see plugin execution logs:

```bash
# Claude Code logs plugin activity
claude --plugin-dir ./claude-plugin --verbose

# Check hook execution
cat ~/.config/claude/logs/plugin-*.log
```

### Plugin Structure

```
claude-plugin/
├── .claude-plugin/
│   └── manifest.json       # Plugin metadata
├── hooks/
│   ├── hooks.json          # Hook event bindings
│   └── edit-plan.sh        # Plan review trigger
└── install.sh              # Binary installer (auto-download)
```

## Building for Release

Release builds are handled by GitHub Actions when you push a version tag:

```bash
git tag v0.2.0
git push origin v0.2.0
```

This triggers builds for all platforms (Linux, macOS x64/ARM, Windows) and attaches binaries to the GitHub release.

## Running Tests

### Frontend Tests (Vitest)

```bash
npm run test              # Run tests
npm run test:ui           # Open test UI
npm run test:coverage     # Generate coverage
```

### Backend Tests (Cargo)

```bash
cd src-tauri
cargo test               # Run Rust tests
```

### E2E Tests (Playwright)

```bash
npm run test:e2e         # Run E2E tests
npm run test:e2e:ui      # Open Playwright UI
```

### Linting & Formatting

```bash
npm run lint             # oxlint + cargo clippy
npm run lint:fix         # Auto-fix issues
npm run format           # Format all code
npm run format:check     # Check formatting
```

## CI/CD

All PRs run the full test suite:
- Frontend tests (Vitest)
- Backend tests (Cargo)
- E2E tests (Playwright)
- Linting (oxlint + Clippy)
- Formatting checks (Prettier + rustfmt)

Release builds trigger on version tags and build binaries for all platforms.
