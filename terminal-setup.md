# Ghostty + tmux Terminal Setup

This setup is designed for a keyboard-driven workflow in Ghostty, with tmux handling pane and window management, zsh providing fast shell defaults, and git aliases keeping common repo actions short.

## Installation

### Prerequisites

- macOS (zsh is included by default)
- [Homebrew](https://brew.sh) (installed automatically by `setup.sh` if missing)

### Quick Start

```bash
git clone <your-repo-url> ~/Desktop/home
cd ~/Desktop/home
./setup.sh
```

The script will:
1. Install Homebrew if it isn't already present
2. `brew install` all dependencies (Ghostty, tmux, git, gh, lazygit, fzf, eza, bat, ripgrep, fd, zoxide, delta, zsh-syntax-highlighting, zsh-autosuggestions)
3. Symlink each config file to its expected location (backing up any existing files)
4. Make `dev-session` executable

### Manual Install (if you prefer)

```bash
brew install ghostty tmux git gh lazygit \
  zsh-syntax-highlighting zsh-autosuggestions \
  fzf eza bat ripgrep fd zoxide git-delta \
  dust btop
```

Then symlink the files yourself:

```bash
ln -s ~/Desktop/home/ghostty/config  ~/.config/ghostty/config
ln -s ~/Desktop/home/tmux.conf       ~/.tmux.conf
ln -s ~/Desktop/home/zshrc           ~/.zshrc
ln -s ~/Desktop/home/gitconfig       ~/.gitconfig
ln -s ~/Desktop/home/dev-session     ~/.local/bin/dev-session
chmod +x ~/Desktop/home/dev-session
```

## What Is Configured

### Ghostty

Ghostty is configured as the terminal renderer, with tmux handling layout and session management.

Current settings:
- `font-family = Menlo`
- `font-size = 15`
- `background-opacity = 0.96`
- `window-padding-x = 10`
- `window-padding-y = 10`
- `cursor-style = block`
- `copy-on-select = true`
- `macos-option-as-alt = true`
- `window-save-state = always`
- `confirm-close-surface = false`
- `term = xterm-256color`

Effect:
- Slight transparency without losing readability
- Comfortable padding
- Option key behaves like Alt/Meta for terminal shortcuts
- Window state persists between launches
- Closing a terminal surface is faster because confirmation is disabled
- Explicit `TERM` ensures correct true color and undercurl passthrough with tmux

Config file:
- `~/.config/ghostty/config`

### tmux

tmux is the core of the workspace layout.

Current behavior:
- True color (24-bit) and undercurl passthrough are enabled
- Mouse support is enabled
- Scrollback history is increased to `100000`
- Windows and panes start at index `1`
- Copy mode uses vim-style keys with `v` to select, `y` to yank to system clipboard
- Window numbers are renumbered automatically
- The default prefix is changed from `Ctrl-b` to `Ctrl-a`
- Clipboard integration is enabled
- Escape timing is reduced for snappier key handling

Pane and window shortcuts:
- `Ctrl-a c`: create a new window in the current directory
- `Ctrl-a |`: split horizontally in the current directory
- `Ctrl-a -`: split vertically in the current directory
- `Ctrl-a h/j/k/l`: move between panes
- `Ctrl-a H/J/K/L`: resize panes in 5-cell steps
- `Ctrl-a r`: reload tmux config

Copy mode shortcuts:
- `Ctrl-a [`: enter copy mode
- `v`: begin selection
- `y`: yank selection to system clipboard
- `Ctrl-v`: toggle rectangle selection

Status line:
- Shown at the top
- Session name on the left
- Date and time on the right

Config file:
- `~/.tmux.conf`

### zsh

zsh is set up for terminal-heavy development with practical defaults.

Current behavior:
- `EDITOR=vim`
- `PAGER=less`
- `LESS=-FRX`
- `~/.local/bin` is added to `PATH`
- History size is set to `100000`
- Shared and appended history are enabled
- All duplicate and leading-space history entries are filtered
- Git branch information is shown in the prompt through `vcs_info`
- Syntax highlighting shows valid/invalid commands in real time
- Autosuggestions show ghost-text from history as you type (accept with `→` or `Ctrl-f`)
- fzf provides fuzzy `Ctrl-r` history search, `**<Tab>` path completion, and `Alt-c` directory jumping
- zoxide tracks frequently visited directories (`z project` to jump)

Prompt behavior:
- Shows `user@host`
- Shows current directory
- Shows current git branch when inside a repository
- Shows a green prompt on success and red on failure

Modern CLI aliases:
- `ls`: `eza` with directories first
- `ll`: long listing with git status column
- `la`: list including hidden files
- `lt`: tree view (2 levels deep)
- `cat`: `bat` with syntax highlighting
- `grep`: `rg` (ripgrep, respects `.gitignore`)
- `find`: `fd` (faster, respects `.gitignore`)
- `du`: `dust` (intuitive disk usage viewer)
- `top`: `btop` (modern resource monitor)
- `diff`: `delta` (syntax-highlighted diffs)
- `lg`: `lazygit`
- `..`: go up one directory
- `...`: go up two directories

Workflow aliases:
- `ta`: attach to tmux session `main`, or create it
- `tls`: list tmux sessions
- `gs`: `git status -sb`
- `ga`: `git add`
- `gc`: `git commit`
- `gca`: `git commit --amend`
- `gco`: `git checkout`
- `gb`: `git branch`
- `gd`: `git diff` (uses delta for syntax-highlighted diffs)
- `gl`: `git pull --ff-only`
- `gp`: `git push`
- `glog`: graph log shortcut
- `gtree`: git history tree shortcut

Helper function:
- `dev`: launches `dev-session` using the current folder name as the tmux session name unless one is provided

File finding:
- `fd pattern`: find files (faster than `find`, respects `.gitignore`)
- `z dirname`: jump to a frequently visited directory

Config file:
- `~/.zshrc`

### git

git is configured for cleaner defaults and shorter command aliases.

Current behavior:
- Default branch is `main`
- Pulls are fast-forward only
- Fetch prunes deleted remote branches
- Color output is enabled
- Pager is `delta` with syntax highlighting and line numbers
- Merge conflicts use `diff3` style for clearer resolution

Aliases:
- `git st`: short status
- `git co`: checkout
- `git br`: branch
- `git ci`: commit
- `git aa`: add all
- `git last`: last commit with stats
- `git lg`: graph log view
- `git tree`: graph log view

Config file:
- `~/.gitconfig`

## Multi-Window Development Workflow

The reusable launcher is `~/.local/bin/dev-session`.

Behavior:
- Accepts a session name as the first argument
- Uses the current working directory unless a second path argument is provided
- Creates a tmux session only if it does not already exist
- Builds a default layout:
  - Window 1: `shell`
  - Window 2: `editor`
  - Window 3: `git`
- The `shell` window starts with multiple panes
- The `editor` window launches `$EDITOR` in the project root automatically
- The `git` window runs `git status -sb` automatically
- If the session already exists, it simply attaches

Common usage:
- `dev`
- `dev myproject`
- `dev myproject /path/to/project`

Recommended daily flow:
1. Open Ghostty.
2. Change into a project directory.
3. Run `dev`.
4. Use the first window for commands, the second for editing, and the third for git checks.
5. Use tmux windows and pane navigation instead of opening many separate terminal tabs.

## How To Reload Everything

After changing config files:
- Reload zsh: `source ~/.zshrc`
- Reload tmux: `Ctrl-a r`
- Restart Ghostty if terminal rendering settings change

## Validation

Use these checks to confirm the setup is working:

### Ghostty

- Open Ghostty and confirm the font size, padding, and opacity are applied
- Confirm the Option key works as Alt in terminal shortcuts
- Confirm selecting text copies it immediately

### tmux

- Run `tmux`
- Verify the prefix is `Ctrl-a`
- Create panes with `Ctrl-a |` and `Ctrl-a -`
- Move between panes with `Ctrl-a h/j/k/l`
- Confirm the status bar appears at the top

### zsh

- Run `source ~/.zshrc`
- Move into a git repository and confirm the prompt shows the branch name
- Run `ll`, `gs`, and `gtree` to verify aliases resolve correctly

### git

- Run `git config --get pull.ff` and confirm it returns `only`
- Run `git tree` in a repository and confirm the graph log view appears

### dev-session

- Run `dev`
- Confirm tmux opens or attaches
- Confirm the windows `shell`, `editor`, and `git` exist
- Confirm the `git` window runs a status command on launch

## Notes

This setup assumes:
- Ghostty is installed and used as the primary terminal
- tmux is available on the system
- zsh is the interactive shell
- `vim` is acceptable as the default editor
- The current configuration should be documented as-is rather than redesigned

If this setup is expanded later, the next logical additions are:
- a tmux plugin manager
- a more advanced prompt theme (starship)
- project-specific tmux layouts
- neovim as the default editor
