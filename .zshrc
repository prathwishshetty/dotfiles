# Fast, practical defaults for terminal-heavy work.
export EDITOR=vim
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
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt INTERACTIVE_COMMENTS
setopt PROMPT_SUBST

autoload -Uz colors vcs_info
colors

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' %F{214}[%b]%f'

precmd() {
  vcs_info
}

PROMPT='%F{81}%n@%m%f %F{39}%1~%f${vcs_info_msg_0_}
%(?.%F{76}.%F{196})%# %f'

alias ls='ls -G'
alias ll='ls -lah'
alias la='ls -A'
alias ..='cd ..'
alias ...='cd ../..'

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

dev() {
  dev-session "${1:-$(basename "$PWD")}"
}
