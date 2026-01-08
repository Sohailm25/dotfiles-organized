#!/bin/bash
# ABOUTME: Master setup script for dotfiles with LaunchAgents and clawdbot ecosystem
# ABOUTME: Processes templates, creates directories, and loads LaunchAgents

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_FILE="${HOME}/.dotfiles-secrets"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check for secrets file
if [ ! -f "$SECRETS_FILE" ]; then
    error "Secrets file not found: $SECRETS_FILE"
    echo ""
    echo "Create it by copying the template:"
    echo "  cp $DOTFILES_DIR/launchagents/Library/LaunchAgents/.env.template ~/.dotfiles-secrets"
    echo "  chmod 600 ~/.dotfiles-secrets"
    echo "  # Then edit and fill in your actual values"
    exit 1
fi

info "Loading secrets from $SECRETS_FILE"
set -a
source "$SECRETS_FILE"
set +a

# Export HOME for envsubst
export HOME

# Create required directories
info "Creating required directories..."
mkdir -p ~/.clawdis/logs
mkdir -p ~/.clawdis/credentials
mkdir -p ~/.clawdis/sessions
mkdir -p ~/.clawdis/media
mkdir -p ~/clawd/memory
mkdir -p ~/Library/LaunchAgents
mkdir -p ~/Library/Logs

# Process LaunchAgent templates
info "Processing LaunchAgent templates..."
for template in "$DOTFILES_DIR"/launchagents/Library/LaunchAgents/*.plist.template; do
    [ -f "$template" ] || continue
    output="${template%.template}"
    output="${output/$DOTFILES_DIR\/launchagents/$HOME}"

    envsubst < "$template" > "$output"
    info "  Generated: $(basename "$output")"
done

# Process clawdis config template
info "Processing clawdis config..."
if [ -f "$DOTFILES_DIR/clawdis/.clawdis/clawdis.json.template" ]; then
    envsubst < "$DOTFILES_DIR/clawdis/.clawdis/clawdis.json.template" > ~/.clawdis/clawdis.json
    chmod 600 ~/.clawdis/clawdis.json
    info "  Generated: ~/.clawdis/clawdis.json"
fi

# Process clawd memory template
info "Processing clawd memory template..."
if [ -f "$DOTFILES_DIR/clawd/clawd/memory.md.template" ]; then
    envsubst < "$DOTFILES_DIR/clawd/clawd/memory.md.template" > ~/clawd/memory.md
    info "  Generated: ~/clawd/memory.md"
fi

# Copy clawdis skills (symlinks don't work well here)
info "Setting up clawdis skills..."
if [ -d "$DOTFILES_DIR/clawdis/.clawdis/skills" ]; then
    cp -r "$DOTFILES_DIR/clawdis/.clawdis/skills" ~/.clawdis/
    info "  Copied skills to ~/.clawdis/skills/"
fi

# Install slack-bridge dependencies
info "Installing slack-bridge dependencies..."
if [ -d ~/clawd/slack-bridge ] && [ -f ~/clawd/slack-bridge/package.json ]; then
    (cd ~/clawd/slack-bridge && npm install --silent)
    info "  Installed slack-bridge node_modules"
fi

# Unload existing LaunchAgents (ignore errors)
info "Unloading existing LaunchAgents..."
for plist in com.sohail.slack-bot com.clawd.slack-bridge com.steipete.clawdis.gateway com.sohail.bookmark-sync; do
    launchctl unload ~/Library/LaunchAgents/${plist}.plist 2>/dev/null || true
done

# Load LaunchAgents
info "Loading LaunchAgents..."
for plist in com.sohail.slack-bot com.clawd.slack-bridge com.steipete.clawdis.gateway com.sohail.bookmark-sync; do
    plist_path=~/Library/LaunchAgents/${plist}.plist
    if [ -f "$plist_path" ]; then
        launchctl load "$plist_path"
        info "  Loaded: $plist"
    else
        warn "  Not found: $plist_path"
    fi
done

echo ""
info "Setup complete!"
echo ""
echo "Verify agents are running:"
echo "  launchctl list | grep -E 'sohail|clawd|steipete'"
echo ""
echo "Check logs:"
echo "  tail -f ~/.clawdis/logs/gateway.log"
echo "  tail -f ~/.clawdis/logs/slack-bridge.log"
echo "  tail -f ~/Library/Logs/slack-bot.log"
