[[ $OSTYPE == linux* ]] || return 0

alias ls='ls --color=auto'

function ghost_mode() {
  sudo service mariadb stop
  sudo service avahi-daemon stop
  sudo service cups stop
  sudo service tor stop
  sudo service smbd stop
  service --status-all
}
