# Development Environment Tools

> Complete inventory of tools and their configurations managed in this repo.

## Stow Packages

| Package | Config Location | Purpose |
|---------|-----------------|---------|
| aerospace | `~/.aerospace.toml` | Tiling window manager |
| atuin | `~/.config/atuin/config.toml` | Shell history sync |
| barik | `~/.barik-config.toml` | Menu bar status widget |
| borders | `~/.config/borders/bordersrc` | Window border styling |
| btop | `~/.config/btop/btop.conf` | System resource monitor |
| fastfetch | `~/.config/fastfetch/config.jsonc` | System info display |
| fish | `~/.config/fish/` | Alternative shell |
| gh | `~/.config/gh/config.yml` | GitHub CLI |
| ghostty | `~/.config/ghostty/config` | GPU-accelerated terminal |
| git | `~/.gitconfig` | Git configuration |
| kitty | `~/.config/kitty/kitty.conf` | Primary terminal emulator |
| markdownlint | `~/.markdownlint.json`, `~/.markdownlint-cli2.yaml` | Markdown linting |
| nvim | `~/.config/nvim/` | Neovim editor (LazyVim) |
| p10k | `~/.p10k.zsh` | Powerlevel10k prompt theme |
| sketchybar | `~/.config/sketchybar/` | Custom menu bar |
| tmux | `~/.tmux.conf` | Terminal multiplexer |
| zsh | `~/.zshrc` | Primary shell |

## Tools by Category

### Window Management
- **Aerospace** - Tiling window manager for macOS (i3-like)
- **Borders** - Adds colored borders to focused windows

### Terminal Emulators
- **Kitty** - Primary terminal, GPU-accelerated, Catppuccin Mocha theme
- **Ghostty** - Secondary terminal, fast startup, same theme

### Terminal Multiplexer
- **tmux** - Session management, panes, windows

### Shell
- **Zsh** - Primary shell with Oh My Zsh
- **Fish** - Alternative shell (interactive features)
- **Powerlevel10k** - Fast, customizable prompt
- **Atuin** - Shell history sync across machines

### Menu Bar
- **Barik** - Lightweight status bar widgets
- **Sketchybar** - Fully customizable menu bar (Lua config)

### Editor
- **Neovim** - LazyVim distribution, Catppuccin theme

### Dev Tools
- **Git** - Version control
- **GitHub CLI (gh)** - GitHub from terminal

### System Utilities
- **btop** - Resource monitor (htop alternative)
- **fastfetch** - System info (neofetch alternative)
- **fzf** - Fuzzy finder
- **zoxide** - Smart cd
- **eza** - Modern ls
- **bat** - Modern cat

### Linting
- **markdownlint** - Markdown style enforcement

## Theme: Catppuccin Mocha

All tools use the **Catppuccin Mocha** color scheme for consistency:
- Kitty, Ghostty, tmux, Neovim, btop

## Not Managed Here

These configs are **intentionally excluded**:
- `~/.secrets` - API keys (never commit)
- `~/.config/nix/`, `~/.config/nix-darwin/` - Nix configs (separate management)
- IDE configs (VS Code, Cursor) - Sync via their own mechanisms
