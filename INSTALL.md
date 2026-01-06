# New Machine Setup Guide

> One-liner commands to install everything on a fresh Mac.

## Prerequisites

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Quick Install (Everything)

```bash
# Add required taps
brew tap nikitabobko/tap
brew tap FelixKratz/formulae
brew tap joshmedeski/sesh

# Install all tools in one command
brew install --cask nikitabobko/tap/aerospace ghostty kitty
brew install stow tmux neovim fish fzf sesh zoxide atuin eza bat btop fastfetch gh borders sketchybar
```

## Individual Tool Installation

### Window Management

| Tool | Install Command | Description |
|------|-----------------|-------------|
| **Aerospace** | `brew install --cask nikitabobko/tap/aerospace` | i3-like tiling window manager |
| **Borders** | `brew tap FelixKratz/formulae && brew install borders` | Window border highlighting |

### Terminal Emulators

| Tool | Install Command | Description |
|------|-----------------|-------------|
| **Kitty** | `brew install --cask kitty` | GPU-accelerated terminal |
| **Ghostty** | `brew install --cask ghostty` | Fast, native terminal |

### Terminal Multiplexer

| Tool | Install Command | Description |
|------|-----------------|-------------|
| **tmux** | `brew install tmux` | Terminal multiplexer |
| **sesh** | `brew tap joshmedeski/sesh && brew install sesh` | tmux session manager |

### Shell & Prompt

| Tool | Install Command | Description |
|------|-----------------|-------------|
| **Fish** | `brew install fish` | User-friendly shell |
| **Oh My Zsh** | `sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"` | Zsh framework |
| **Powerlevel10k** | `brew install powerlevel10k` | Fast Zsh prompt |
| **Atuin** | `brew install atuin` | Shell history sync |
| **Zoxide** | `brew install zoxide` | Smart cd command |
| **fzf** | `brew install fzf` | Fuzzy finder |

### Menu Bar

| Tool | Install Command | Description |
|------|-----------------|-------------|
| **Sketchybar** | `brew tap FelixKratz/formulae && brew install sketchybar` | Custom menu bar |
| **Barik** | [Download from GitHub](https://github.com/qusaismael/barik/releases) | Lightweight status bar |

### Editor

| Tool | Install Command | Description |
|------|-----------------|-------------|
| **Neovim** | `brew install neovim` | Modern Vim |

### CLI Utilities

| Tool | Install Command | Description |
|------|-----------------|-------------|
| **eza** | `brew install eza` | Modern `ls` replacement |
| **bat** | `brew install bat` | Modern `cat` with syntax highlighting |
| **btop** | `brew install btop` | Resource monitor |
| **fastfetch** | `brew install fastfetch` | System info display |
| **gh** | `brew install gh` | GitHub CLI |

## Post-Install: Apply Dotfiles

```bash
# Clone dotfiles
git clone git@github.com:Sohailm25/dotfiles-organized.git ~/dotfiles

# Backup existing configs (if any)
mkdir -p ~/.config-backup
[ -f ~/.zshrc ] && mv ~/.zshrc ~/.config-backup/
[ -f ~/.tmux.conf ] && mv ~/.tmux.conf ~/.config-backup/
[ -d ~/.config/nvim ] && mv ~/.config/nvim ~/.config-backup/
[ -d ~/.config/kitty ] && mv ~/.config/kitty ~/.config-backup/

# Stow all configs
cd ~/dotfiles && stow */

# Create secrets file (API keys - not in git)
cat > ~/.secrets << 'EOF'
export LINEAR_API_KEY="your-key"
export MONDAY_API_KEY="your-key"
export LIMITLESS_API_KEY="your-key"
EOF
chmod 600 ~/.secrets
```

## Tool-Specific Setup

### Aerospace
```bash
# Start at login (automatic via config)
# Grant accessibility permissions when prompted
open -a AeroSpace
```

### Borders
```bash
# Start borders service
brew services start borders
```

### Sketchybar
```bash
# Hide default menu bar: System Settings → Control Center →
# "Automatically hide and show the menu bar" → Always

# Start sketchybar
brew services start sketchybar
```

### Barik
```bash
# Download latest release
open https://github.com/qusaismael/barik/releases

# Move to Applications, then open
# Grant accessibility permissions when prompted
```

### tmux Plugins
```bash
# Install TPM (Tmux Plugin Manager)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Open tmux, then press: Ctrl+Space, I (capital I) to install plugins
```

### Atuin
```bash
# Start daemon
brew services start atuin

# Import existing history
atuin import auto

# Login (optional - for sync)
atuin login
```

### Fish Shell (if using as default)
```bash
# Add to available shells
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells

# Set as default (optional)
chsh -s /opt/homebrew/bin/fish
```

### GitHub CLI
```bash
# Authenticate
gh auth login
```

## System Settings

### Required for Aerospace
- **No SIP disable needed** (unlike yabai)
- Grant Accessibility permissions when prompted

### Required for Sketchybar
- System Settings → Control Center → "Automatically hide and show the menu bar" → **Always**
- System Settings → Desktop & Dock → "Displays have separate Spaces" → **On** (default)

### Required for Borders
- macOS Sonoma (14.0) or later required

## Verify Installation

```bash
# Check all tools are installed
which aerospace kitty ghostty tmux nvim fish fzf zoxide atuin eza bat btop fastfetch gh borders sketchybar

# Check stow symlinks
ls -la ~/.aerospace.toml ~/.tmux.conf ~/.zshrc ~/.config/kitty ~/.config/ghostty ~/.config/nvim
```

## Troubleshooting

### Aerospace not responding
```bash
# Restart Aerospace
aerospace reload-config
# Or quit and reopen the app
```

### Borders not showing
```bash
# Check if running
pgrep borders
# Start manually
borders &
```

### Sketchybar not appearing
```bash
# Restart service
brew services restart sketchybar
# Check logs
tail -f /tmp/sketchybar_$USER.err.log
```

### tmux plugins not loading
```bash
# Reinstall TPM
rm -rf ~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# Then in tmux: Ctrl+Space, I
```
