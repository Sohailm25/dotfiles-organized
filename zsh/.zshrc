# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"



# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git iterm2 zsh-autosuggestions zsh-syntax-highlighting you-should-use zsh-bat)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export PATH="/run/current-system/sw/bin:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Helper to hit the local agent server at 127.0.0.1:8081.
agent() {
  local msg="$*"
  if [[ -z "$msg" ]]; then
    echo "Usage: agent <message>"
    return 1
  fi
  local force_env="${AGENT_FORCE_SEARCH:-1}"
  local force_json=true
  if [[ "$force_env" == "0" ]]; then
    force_json=false
  fi
  curl -s -X POST http://127.0.0.1:8081/chat \
    -H "Content-Type: application/json" \
    -d "$(jq -nc \
      --arg message "$msg" \
      --argjson force_search ${force_json} \
      '{message:$message, force_search:$force_search}')" \
    | jq -r '.reply'
}

# Launch the local agent server from any directory.
agent-run() {
  local repo="$HOME/Repos/experiments/local_agent"
  if [[ ! -f "$repo/.venv/bin/activate" ]]; then
    echo "Missing virtualenv at $repo/.venv; run python3 -m venv there first."
    return 1
  fi
  (
    cd "$repo" || exit 1
    source .venv/bin/activate
    python3 agent_server.py "$@"
  )
}

alias ls="eza"
alias ll="eza -alh"
alias tree="eza --tree"
alias cat="bat"
alias today='nvim $(date +%m_%d_%Y).md'
alias n="nvim"
alias oc="opencode"
alias lin='nvim -c "Linear"'
export PATH="$HOME/usr/local/bin:$PATH"
eval "$(zoxide init zsh)"

alias genai="node ~/tools/AI-scripts/dist/GenAI.js"
alias holefill="node ~/tools/AI-scripts/dist/HoleFill.js"
alias repomanager="node ~/tools/AI-scripts/dist/RepoManager.js"
alias pro="npx -y @steipete/oracle --engine browser -p "
alias chatshl='cd ~/tools/AI-scripts && bun ChatSH.ts l'
export PATH="$HOME/go/bin:$PATH"


. "$HOME/.local/bin/env"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/sohailmo/.lmstudio/bin"
# End of LM Studio CLI section

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Added by microsandbox installer
export PATH="$HOME/.local/bin:$PATH"
export DYLD_LIBRARY_PATH="$HOME/.local/lib:$DYLD_LIBRARY_PATH"

# bun completions
[ -s "/Users/sohailmo/.bun/_bun" ] && source "/Users/sohailmo/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/Library/Python/3.9/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# Amp CLI
export PATH="/Users/sohailmo/.amp/bin:$PATH"

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"

# opencode
export PATH=/Users/sohailmo/.opencode/bin:$PATH


# Load secrets (API keys) from separate file not tracked in git
[ -f ~/.secrets ] && source ~/.secrets

# pnpm
export PNPM_HOME="/Users/sohailmo/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# >>> MCP Agent Mail bd path /Users/sohailmo/.local/bin
if [[ ":$PATH:" != *":/Users/sohailmo/.local/bin:"* ]]; then
  export PATH="/Users/sohailmo/.local/bin:$PATH"
fi
# <<< MCP Agent Mail bd path

# >>> MCP Agent Mail alias
alias am='cd "/Users/sohailmo/mcp_agent_mail" && scripts/run_server_with_token.sh'
# <<< MCP Agent Mail alias
