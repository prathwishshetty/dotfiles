#!/bin/bash
set -eu
set -o pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

info() { printf '\033[1;34m==> %s\033[0m\n' "$1"; }
warn() { printf '\033[1;33m==> %s\033[0m\n' "$1"; }

# --- Install Homebrew if missing ---
if ! command -v brew >/dev/null 2>&1; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null)"
fi

# --- Install dependencies ---
info "Installing packages via Homebrew..."
brew install ghostty tmux git gh lazygit \
  zsh-syntax-highlighting zsh-autosuggestions \
  fzf eza bat ripgrep fd zoxide git-delta \
  dust btop

# --- Create directories ---
mkdir -p ~/.config/ghostty
mkdir -p ~/.local/bin

# --- Symlink helper ---
link_file() {
  local src="$1" dst="$2"
  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -e "$dst" ]; then
    warn "Backing up $dst → ${dst}.backup"
    mv "$dst" "${dst}.backup"
  fi
  ln -s "$src" "$dst"
  info "Linked $dst → $src"
}

# --- Symlink dotfiles ---
link_file "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"
link_file "$DOTFILES_DIR/tmux.conf"      "$HOME/.tmux.conf"
link_file "$DOTFILES_DIR/zshrc"          "$HOME/.zshrc"
link_file "$DOTFILES_DIR/gitconfig"      "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/dev-session"    "$HOME/.local/bin/dev-session"

# --- Make dev-session executable ---
chmod +x "$DOTFILES_DIR/dev-session"

# --- Git identity (stored in ~/.gitconfig.local) ---
if [ ! -f "$HOME/.gitconfig.local" ]; then
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
else
  info "~/.gitconfig.local already exists, skipping Git identity setup."
fi

info "Done! Open a new shell to pick up the changes."
