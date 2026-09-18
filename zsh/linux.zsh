[[ $OSTYPE == linux* ]] || return 0

function ghost_mode() {
  sudo service mariadb stop
  sudo service avahi-daemon stop
  sudo service cups stop
  sudo service tor stop
  sudo service smbd stop
  service --status-all
}
