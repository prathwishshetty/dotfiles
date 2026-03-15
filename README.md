# Dotfiles

This repository is organized for [GNU Stow](https://www.gnu.org/software/stow/).

## Layout

Each top-level directory is a Stow package. Inside each package, files are stored at the path where they should appear in `$HOME`.

Examples:

- `zsh/.zshrc` -> `~/.zshrc`
- `git/.gitconfig` -> `~/.gitconfig`
- `tmux/.tmux.conf` -> `~/.tmux.conf`
- `ghostty/.config/ghostty/config` -> `~/.config/ghostty/config`
- `localbin/.local/bin/dev-session` -> `~/.local/bin/dev-session`
- `nvim/.config/nvim/init.lua` -> `~/.config/nvim/init.lua`
- `starship/.config/starship.toml` -> `~/.config/starship.toml`

GitHub may visually collapse single-child directories like `ghostty/.config/ghostty` into one line. That is expected.

## Setup

Install packages from the Brewfile and stow the repo into `$HOME`:

```bash
./setup.sh
```

Homebrew packages and apps live in [`Brewfile`](/Users/prathwish/.dotfiles/Brewfile). Add tools like `uv`, `tmux`, or `ghostty` there instead of hard-coding them in `setup.sh`.

Or run Stow directly:

```bash
stow -R -t "$HOME" zsh git tmux ghostty localbin nvim starship
```

Install only the Homebrew dependencies:

```bash
brew bundle --file Brewfile
```

## Useful Commands

Preview changes:

```bash
stow -n -v -t "$HOME" zsh git tmux ghostty localbin nvim starship
```

Remove packages:

```bash
stow -D -t "$HOME" zsh git tmux ghostty localbin nvim starship
```

Restow after edits:

```bash
stow -R -t "$HOME" zsh git tmux ghostty localbin nvim starship
```
