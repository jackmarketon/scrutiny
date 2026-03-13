# Scrutiny - Claude Code Plugin

**Native plan editor with side-by-side diffs and inline commenting.**

## Installation

Install directly from this repository:

```bash
claude plugin add https://github.com/jackmarketon/scrutiny
```

The installer will automatically:
- Detect your platform (Linux, macOS x64/ARM, Windows)
- Download the correct binary from GitHub releases
- Install it in the plugin directory
- Set up the plan review hook

## Usage

When Claude Code presents a plan for review:

1. **Scrutiny launches automatically** — No manual steps needed
2. **Review the plan** — Side-by-side diff view shows original vs your edits
3. **Add comments** — Click any line to leave inline feedback
4. **Edit directly** — Make changes in the CodeMirror editor
5. **Approve** — Click "Approve & Send Feedback"

Claude receives your feedback and responds accordingly.

## Updates

The plugin automatically checks for updates on install. To update manually:

```bash
# Re-run the installer
~/.config/claude/plugins/scrutiny/install.sh
```

## Requirements

- Claude Code v0.2.0 or newer
- macOS, Linux, or Windows

## Features

- ✅ Side-by-side diff view
- ✅ Inline comments
- ✅ Full editing with syntax highlighting
- ✅ Real-time diff updates
- ✅ Native performance (Rust + Tauri)
- ✅ Dark theme
- ✅ Cross-platform

## Development

See [DEVELOPMENT.md](../DEVELOPMENT.md) for local testing and contribution guidelines.

## Support

- 📝 [GitHub Issues](https://github.com/jackmarketon/scrutiny/issues)
- 💬 [Discussions](https://github.com/jackmarketon/scrutiny/discussions)
- 📖 [Documentation](https://github.com/jackmarketon/scrutiny/blob/main/README.md)

## License

MIT — see [LICENSE](../LICENSE)
