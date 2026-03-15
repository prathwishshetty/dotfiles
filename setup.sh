#!/bin/bash
set -eu
set -o pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGES=(zsh git tmux ghostty localbin nvim starship)

info() { printf '\033[1;34m==> %s\033[0m\n' "$1"; }
warn() { printf '\033[1;33m==> %s\033[0m\n' "$1"; }
fail() { printf '\033[1;31m==> %s\033[0m\n' "$1"; }

ensure_brew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null)"
}

install_packages() {
  local brewfile="$DOTFILES_DIR/Brewfile"

  if [ ! -f "$brewfile" ]; then
    fail "Missing Brewfile at $brewfile"
    exit 1
  fi

  info "Installing packages from Brewfile..."
  brew bundle --file "$brewfile"
}

backup_conflict() {
  local target="$1"

  if [ -L "$target" ]; then
    local link_target
    link_target="$(readlink "$target" || true)"
    if [[ "$link_target" != "$DOTFILES_DIR"* ]]; then
      info "Removing conflicting symlink $target -> $link_target"
      rm -f "$target"
    fi
    return
  fi

  if [ -e "$target" ]; then
    local backup="${target}.backup.$(date +%Y%m%d%H%M%S)"
    warn "Backing up $target -> $backup"
    mv "$target" "$backup"
  fi
}

prepare_targets() {
  mkdir -p "$HOME/.config/ghostty" "$HOME/.config/nvim" "$HOME/.local/bin"

  backup_conflict "$HOME/.zshrc"
  backup_conflict "$HOME/.gitconfig"
  backup_conflict "$HOME/.tmux.conf"
  backup_conflict "$HOME/.config/ghostty/config"
  backup_conflict "$HOME/.local/bin/dev-session"
  backup_conflict "$HOME/.config/nvim/init.lua"
  backup_conflict "$HOME/.config/starship.toml"
}

stow_packages() {
  info "Previewing Stow changes..."
  stow -n -v -t "$HOME" "${PACKAGES[@]}"

  info "Applying Stow packages..."
  stow -R -t "$HOME" "${PACKAGES[@]}"
}

install_tpm() {
  if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    info "TPM already installed, skipping."
    return
  fi

  info "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
}

setup_git_identity() {
  if [ -f "$HOME/.gitconfig.local" ]; then
    info "~/.gitconfig.local already exists, skipping Git identity setup."
    return
  fi

  info "Setting up Git identity..."
  printf "Enter your Git name: "
  read -r git_name
  printf "Enter your Git email: "
  read -r git_email
  cat > "$HOME/.gitconfig.local" <<EOF
[user]
	name = $git_name
	email = $git_email
EOF
  info "Saved Git identity to ~/.gitconfig.local"
}

ensure_brew
install_packages
prepare_targets
stow_packages
install_tpm
setup_git_identity

info "Done! Open a new shell to pick up the changes."
