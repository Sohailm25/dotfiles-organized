# Sohail's Terminal Environment

> Dotfiles managed with GNU Stow. Clone and `stow */` to set up.

## Quick Reference Card

```
╔═══════════════════════════════════════════════════════════════════╗
║  AEROSPACE (Cmd)              │  TMUX (Ctrl)                      ║
║  ─────────────────────────────┼───────────────────────────────────║
║  Cmd + 1-9      → Workspace   │  Ctrl + Space    → Prefix         ║
║  Cmd + Arrow    → Focus Win   │  Ctrl + Arrow    → Navigate Pane  ║
║  Cmd + K        → New Kitty   │  Ctrl + 1-9      → Switch Window  ║
║  Cmd + L        → New Ghostty │                                   ║
║                               │  Prefix + T      → Session Picker ║
║                               │  Prefix + | / -  → Split Pane     ║
╚═══════════════════════════════════════════════════════════════════╝
```

## System Overview

| Layer | Tool | Config Location | Theme |
|-------|------|-----------------|-------|
| OS Window Manager | Aerospace | `~/.aerospace.toml` | - |
| Terminal Emulator | Kitty | `~/.config/kitty/kitty.conf` | Catppuccin Mocha |
| Terminal Emulator | Ghostty | `~/.config/ghostty/config` | Catppuccin Mocha |
| Terminal Multiplexer | tmux | `~/.tmux.conf` | Catppuccin Mocha |
| Shell | Zsh + Oh My Zsh | `~/.zshrc` | Powerlevel10k |
| Editor | Neovim (LazyVim) | `~/.config/nvim/` | Catppuccin |
| Menu Bar | Barik | `~/.barik-config.toml` | - |

> See [TOOLS.md](TOOLS.md) for complete tool inventory.

## Modifier Key Philosophy

| Modifier | Domain | Purpose |
|----------|--------|---------|
| `Cmd (⌘)` | **Aerospace** | OS-level window/workspace management |
| `Ctrl` | **tmux** | Terminal multiplexer operations |
| `Alt` | **Reserved** | Shell shortcuts (word nav: Alt+b/f) |
| `Space` | **Neovim** | Editor leader key |

---

## Keybinding Reference

### Aerospace (OS Windows & Workspaces)

| Keybinding | Action |
|------------|--------|
| `Cmd + ←/→/↑/↓` | Focus window in direction |
| `Cmd + Shift + ←/→/↑/↓` | Move window in direction |
| `Cmd + 1-9` | Switch to workspace 1-9 |
| `Alt + Shift + 1-9` | Move window to workspace 1-9 |
| `Cmd + /` | Toggle horizontal/vertical layout |
| `Cmd + ,` | Toggle accordion layout |
| `Cmd + B` | Open browser |
| `Cmd + K` | Open new Kitty terminal |
| `Cmd + L` | Open new Ghostty terminal |
| `Cmd + O` | Open Obsidian |
| `Alt + Tab` | Workspace back-and-forth |

### tmux (Terminal Multiplexer)

**Prefix: `Ctrl + Space`**

#### Pane Operations (no prefix needed)
| Keybinding | Action |
|------------|--------|
| `Ctrl + ←` | Navigate to left pane |
| `Ctrl + →` | Navigate to right pane |
| `Ctrl + ↑` | Navigate to pane above |
| `Ctrl + ↓` | Navigate to pane below |

#### Window Operations (no prefix needed)
| Keybinding | Action |
|------------|--------|
| `Ctrl + 1-9` | Switch to window 1-9 |

#### Pane Management (prefix required)
| Keybinding | Action |
|------------|--------|
| `Prefix + \|` | Split vertically (side by side) |
| `Prefix + -` | Split horizontally (top/bottom) |
| `Prefix + x` | Close pane |
| `Prefix + z` | Zoom pane (fullscreen toggle) |
| `Prefix + H/J/K/L` | Resize pane |
| `Prefix + {` | Swap pane left |
| `Prefix + }` | Swap pane right |

#### Window Management (prefix required)
| Keybinding | Action |
|------------|--------|
| `Prefix + c` | Create new window |
| `Prefix + &` | Close window |
| `Prefix + ,` | Rename window |
| `Prefix + n` | Next window |
| `Prefix + p` | Previous window |

#### Session Management
| Keybinding | Action |
|------------|--------|
| `Prefix + T` | Session picker (sesh + fzf) |
| `Prefix + d` | Detach from session |
| `Prefix + $` | Rename session |
| `Prefix + s` | List sessions |
| `Prefix + Ctrl+s` | Save session (resurrect) |
| `Prefix + Ctrl+r` | Restore session (resurrect) |

#### Copy Mode (Vim-style)
| Keybinding | Action |
|------------|--------|
| `Prefix + [` | Enter copy mode |
| `v` | Begin selection |
| `y` | Yank (copy) |
| `Prefix + ]` | Paste |

### Neovim

**Leader: `Space`**

| Keybinding | Action |
|------------|--------|
| `Ctrl + ←/→/↑/↓` | Navigate splits (seamless with tmux) |
| `Alt + ←/→/↑/↓` | Resize splits |
| `<leader>e` | File explorer |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>z` | Zen mode |

### Shell (Zsh)

| Keybinding | Action |
|------------|--------|
| `Ctrl + r` | Search history (atuin) |
| `Ctrl + t` | Fuzzy find files (fzf) |
| `Alt + c` | Fuzzy cd (fzf) |
| `Alt + b` | Jump word backward |
| `Alt + f` | Jump word forward |
| `z <partial>` | Smart cd (zoxide) |

---

## Installation (New Machine)

```bash
# 1. Clone dotfiles
git clone git@github.com:Sohailm25/dotfiles-organized.git ~/dotfiles

# 2. Install dependencies
brew install stow tmux fzf

# 3. Backup existing configs (if any)
mv ~/.zshrc ~/.zshrc.backup 2>/dev/null
mv ~/.tmux.conf ~/.tmux.conf.backup 2>/dev/null
# ... etc

# 4. Stow all configs
cd ~/dotfiles && stow */

# 5. Create secrets file (not in git)
cat > ~/.secrets << 'EOF'
export LINEAR_API_KEY="your-key"
export MONDAY_API_KEY="your-key"
# etc
EOF
chmod 600 ~/.secrets

# 6. Install tmux plugins
# Open tmux, then press: Ctrl+Space, I (capital I)
```

## Directory Structure

```
~/dotfiles/
├── README.md              ← This file
├── TOOLS.md               ← Complete tool inventory
├── .gitignore
├── .stow-local-ignore
├── aerospace/             ← Window manager
├── atuin/                 ← Shell history
├── barik/                 ← Menu bar widgets
├── borders/               ← Window borders
├── btop/                  ← System monitor
├── fastfetch/             ← System info
├── fish/                  ← Alt shell
├── gh/                    ← GitHub CLI
├── ghostty/               ← Ghostty terminal
├── git/                   ← Git config
├── kitty/                 ← Kitty terminal
├── markdownlint/          ← Markdown linting
├── nvim/                  ← Neovim editor
├── p10k/                  ← Prompt theme
├── sketchybar/            ← Custom menu bar
├── tmux/                  ← Terminal multiplexer
└── zsh/                   ← Primary shell

~/.secrets  ← NOT in git (API keys)
```

## Updating Configs

```bash
# Edit a config (changes are immediately reflected via symlink)
nvim ~/dotfiles/tmux/.tmux.conf

# Reload tmux config
tmux source ~/.tmux.conf

# Commit and push
cd ~/dotfiles
git add -A && git commit -m "Update tmux config" && git push
```

## Adding New Configs

```bash
# 1. Create package directory
mkdir -p ~/dotfiles/newapp/.config/newapp

# 2. Move existing config
mv ~/.config/newapp/config.toml ~/dotfiles/newapp/.config/newapp/

# 3. Stow it
cd ~/dotfiles && stow newapp

# 4. Commit
git add newapp && git commit -m "Add newapp config"
```

## Secrets Management

API keys and sensitive data are stored in `~/.secrets` which is **NOT** tracked in git.

```bash
# Create secrets file
cat > ~/.secrets << 'EOF'
export LINEAR_API_KEY="lin_api_..."
export MONDAY_API_KEY="eyJ..."
export LIMITLESS_API_KEY="sk-..."
export SUPERMEMORY_API_KEY="sm_..."
EOF

# Secure permissions
chmod 600 ~/.secrets
```

The `.zshrc` sources this file: `[ -f ~/.secrets ] && source ~/.secrets`

## Dependencies

| Tool | Installation | Purpose |
|------|--------------|---------|
| stow | `brew install stow` | Symlink manager |
| tmux | `brew install tmux` | Terminal multiplexer |
| fzf | `brew install fzf` | Fuzzy finder |
| sesh | `brew install sesh` | Session manager |
| zoxide | `brew install zoxide` | Smart cd |
| atuin | `brew install atuin` | Shell history |
| eza | `brew install eza` | Modern ls |
| bat | `brew install bat` | Modern cat |

## tmux Plugins (auto-installed)

- **tpm** - Plugin manager
- **tmux-sensible** - Sensible defaults
- **tmux-resurrect** - Save/restore sessions
- **tmux-continuum** - Auto-save sessions

First time: Open tmux, press `Ctrl+Space`, then `I` (capital I) to install plugins.
