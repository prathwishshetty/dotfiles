# Fast, practical defaults for terminal-heavy work.
export EDITOR=nvim
export VISUAL="$EDITOR"
export PAGER=less
export LESS='-FRX'
export PATH="$HOME/.local/bin:$PATH"

HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt AUTO_CD
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt INTERACTIVE_COMMENTS
setopt PROMPT_SUBST

# Modern CLI tool replacements.
alias ls='eza --icons --group-directories-first'
alias ll='eza --icons -lah --git --group-directories-first'
alias la='eza --icons -a --group-directories-first'
alias lt='eza --icons --tree --level=2'
alias cat='bat --paging=never'
alias grep='rg'
alias find='fd'
alias du='dust'
alias top='btop'
alias diff='delta'
alias ..='cd ..'
alias ...='cd ../..'

export MANPAGER="sh -c 'col -bx | bat -l man -p'"

alias ta='tmux attach -t main || tmux new -s main'
alias tls='tmux ls'
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gca='git commit --amend'
alias gco='git checkout'
alias gb='git branch'
alias gd='git diff'
alias gl='git pull --ff-only'
alias gp='git push'
alias glog='git lg'
alias gtree='git tree'
alias lg='lazygit'

dev() {
  dev-session "${1:-$(basename "$PWD")}"
}

# fzf: fuzzy finder keybindings and completion.
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --reverse --border'
source /opt/homebrew/opt/fzf/shell/key-bindings.zsh 2>/dev/null
source /opt/homebrew/opt/fzf/shell/completion.zsh 2>/dev/null

# zoxide: smarter cd.
eval "$(zoxide init zsh 2>/dev/null)"

# Syntax highlighting and autosuggestions (must be near end of .zshrc).
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null

# Starship prompt (must be last).
eval "$(starship init zsh 2>/dev/null)"
