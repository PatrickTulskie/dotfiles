typeset -U path

[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
[ -x /home/linuxbrew/.linuxbrew/bin/brew ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

path=(
  $HOME/.local/bin
  $HOME/agents/bin
  $HOME/dotfiles/bin
  $path
  $HOME/.cargo/bin
  $HOME/.docker/bin
)
path=($^path(N-/))
