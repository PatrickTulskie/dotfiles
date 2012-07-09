# Global Path Override
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin

# Path to your oh-my-zsh configuration.
export ZSH=$HOME/.oh-my-zsh

# Set to the name theme to load.
# Look in ~/.oh-my-zsh/themes/
export ZSH_THEME="jived"

# Set to this to use case-sensitive completion
# export CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
export DISABLE_AUTO_UPDATE="true"

# Plugins
plugins=(osx)

# Uncomment following line if you want to disable colors in ls
# export DISABLE_LS_COLORS="true"

source $ZSH/oh-my-zsh.sh

# Path Setup
source ~/.profile

# Aliases
for dotfile in ~/dotfiles/.zsh_*; do
  source ${dotfile}
done

# RVM
if [ -s ~/.rvm/scripts/rvm ] ; then source ~/.rvm/scripts/rvm ; fi
PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
