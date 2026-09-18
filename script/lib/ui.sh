# Vendored from PatrickTulskie/agents (lib/ui.sh). Source it, then call
# ui_init. Everything draws to stderr.
#
# On a terminal, menus take arrow keys and each answered prompt collapses to one
# line. From a pipe every answer is one line and a menu takes its key or number.
#
# Helpers assign through the caller's variable name, so their locals are
# underscore-prefixed: bash scoping is dynamic, and a local sharing the caller's
# name would have the helper assign to itself instead.

UI_TTY="" UI_COLS=80 UI_ROWS=24 UI_INDEX=0
UI_DIM="" UI_BOLD="" UI_CYAN="" UI_GREEN="" UI_YELLOW="" UI_RED="" UI_INV="" UI_OFF=""

ui_init() {
  local _size=""
  if [[ -t 0 && -t 2 ]]; then
    UI_TTY=1
    _size=$(stty size </dev/tty 2>/dev/null) || _size=""
    if [[ "$_size" =~ ^([0-9]+)\ ([0-9]+)$ ]]; then
      UI_ROWS=${BASH_REMATCH[1]} UI_COLS=${BASH_REMATCH[2]}
    fi
    trap 'printf "\033[?25h" >&2' EXIT
  fi
  if [[ -t 2 && -z "${NO_COLOR:-}" && "${TERM:-dumb}" != "dumb" ]]; then
    UI_DIM=$'\033[2m' UI_BOLD=$'\033[1m' UI_CYAN=$'\033[36m' UI_GREEN=$'\033[32m'
    UI_YELLOW=$'\033[33m' UI_RED=$'\033[31m' UI_INV=$'\033[7m' UI_OFF=$'\033[0m'
  fi
}

ui_line() { printf '%s\n' "$*" >&2; }
ui_path() {
  case "$1" in
    "$HOME"/*) printf '~/%s' "${1#"$HOME"/}" ;;
    *)         printf '%s' "$1" ;;
  esac
}
ui_bar() {
  if [[ $# -eq 0 ]]; then ui_line "${UI_DIM}│${UI_OFF}"
  else ui_line "${UI_DIM}│${UI_OFF}  $*"; fi
}
ui_ok()   { ui_bar "${UI_GREEN}✓${UI_OFF} $*"; }
ui_note() { ui_bar "${UI_DIM}$*${UI_OFF}"; }
ui_warn() { ui_bar "${UI_YELLOW}▲ $*${UI_OFF}"; }
ui_done() { ui_line "${UI_GREEN}◇${UI_OFF}  $1 ${UI_DIM}· $2${UI_OFF}"; }

ui_abort() {
  ui_line "${UI_RED}■${UI_OFF}  $*"
  exit 1
}

ui_intro() { # "name" "tagline" ["line"]...
  ui_line ""
  ui_line "${UI_DIM}┌${UI_OFF}  ${UI_INV} $1 ${UI_OFF}  ${UI_BOLD}$2${UI_OFF}"
  shift 2
  [[ $# -eq 0 ]] || ui_bar
  local _l
  for _l in "$@"; do ui_bar "$_l"; done
}

ui_section() {
  ui_bar
  ui_line "${UI_DIM}├──${UI_OFF} ${UI_CYAN}${UI_BOLD}$1${UI_OFF}"
  ui_bar
}

ui_outro() {
  ui_bar
  ui_line "${UI_DIM}└${UI_OFF}  $*"
  ui_line ""
}

# Rewrites the prompt line just answered as a settled one. Skipped when the line
# could have wrapped, since moving up one row would then clobber the wrong one.
ui_settle() { # "prompt" "answer" <width the prompt line took>
  [[ -n "$UI_TTY" && $3 -lt $UI_COLS ]] || return 0
  printf '\033[1A\r\033[2K' >&2
  ui_done "$1" "$2"
}

ui_ask() { # varname "prompt" [default] -- non-zero on EOF
  local _var="$1" _q="$2" _def="${3:-}" _val=""
  if [[ -n "$_def" ]]; then
    printf '%s◆%s  %s %s(%s)%s › ' "$UI_CYAN" "$UI_OFF" "$_q" "$UI_DIM" "$_def" "$UI_OFF" >&2
  else
    printf '%s◆%s  %s › ' "$UI_CYAN" "$UI_OFF" "$_q" >&2
  fi
  IFS= read -r _val || { printf '\n' >&2; return 1; }
  [[ -n "$_val" ]] || _val="$_def"
  ui_settle "$_q" "${_val:-—}" "$((${#_q} + ${#_def} + ${#_val} + 10))"
  printf -v "$_var" '%s' "$_val"
}

ui_yes() { # "question" <y|n> -- the second argument is the default
  local _q="$1" _yes="" _k="" _rest="" _ans=""
  [[ "$2" != "y" ]] || _yes=1
  if [[ -n "$UI_TTY" ]]; then
    printf '\033[?25l' >&2
    while :; do
      if [[ -n "$_yes" ]]; then
        printf '\r\033[2K%s◆%s  %s  %s● Yes%s %s/ ○ No%s' \
          "$UI_CYAN" "$UI_OFF" "$_q" "$UI_GREEN" "$UI_OFF" "$UI_DIM" "$UI_OFF" >&2
      else
        printf '\r\033[2K%s◆%s  %s  %s○ Yes /%s %s● No%s' \
          "$UI_CYAN" "$UI_OFF" "$_q" "$UI_DIM" "$UI_OFF" "$UI_GREEN" "$UI_OFF" >&2
      fi
      IFS= read -rsn1 _k || ui_abort "Ran out of input at '$_q'"
      case "$_k" in
        ""|" ") break ;;
        y|Y) _yes=1; break ;;
        n|N) _yes=""; break ;;
        h|l|$'\t'|$'\033')
          [[ "$_k" != $'\033' ]] || IFS= read -rsn2 -t 1 _rest || true
          if [[ -n "$_yes" ]]; then _yes=""; else _yes=1; fi ;;
      esac
    done
    printf '\r\033[2K\033[?25h' >&2
    ui_done "$_q" "$([[ -n "$_yes" ]] && echo Yes || echo No)"
  else
    while :; do
      ui_ask _ans "$_q" "$([[ -n "$_yes" ]] && echo Y/n || echo y/N)" || ui_abort "Ran out of input at '$_q'"
      case "$_ans" in
        Y/n|y|Y|yes|Yes) _yes=1; break ;;
        y/N|n|N|no|No)   _yes=""; break ;;
        *) ui_warn "Answer y or n" ;;
      esac
    done
  fi
  [[ -n "$_yes" ]]
}

# The caller's current value is preselected when it matches a key. Sets UI_INDEX
# as well as the key.
ui_select() { # varname "question" <key> "label" "hint" ...
  local _var="$1" _q="$2"; shift 2
  local _keys=() _labels=() _hints=() _n=0 _i _cur=0 _def _k="" _rest="" _ans="" _drawn=""
  while [[ $# -gt 0 ]]; do
    _keys[$_n]="$1" _labels[$_n]="$2" _hints[$_n]="$3"
    [[ "$1" != "${!_var:-}" ]] || _cur=$_n
    _n=$((_n + 1)); shift 3
  done

  ui_line "${UI_CYAN}◆${UI_OFF}  $_q"
  if [[ -n "$UI_TTY" && $((_n + 3)) -lt $UI_ROWS ]]; then
    printf '\033[?25l' >&2
    while :; do
      [[ -z "$_drawn" ]] || printf '\033[%dA' "$((_n + 1))" >&2
      _drawn=1
      for ((_i = 0; _i < _n; _i++)); do
        printf '\r\033[2K' >&2
        if [[ $_i -ne $_cur ]]; then
          ui_line "${UI_DIM}│  ○ ${_labels[$_i]}${UI_OFF}"
        elif [[ -n "${_hints[$_i]}" && $((${#_labels[$_i]} + ${#_hints[$_i]} + 10)) -lt $UI_COLS ]]; then
          ui_bar "${UI_GREEN}●${UI_OFF} ${_labels[$_i]}  ${UI_DIM}${_hints[$_i]}${UI_OFF}"
        else
          ui_bar "${UI_GREEN}●${UI_OFF} ${_labels[$_i]}"
        fi
      done
      printf '\r\033[2K' >&2
      ui_line "${UI_DIM}└  ↑/↓ to move · enter to choose${UI_OFF}"
      IFS= read -rsn1 _k || ui_abort "Ran out of input at '$_q'"
      case "$_k" in
        ""|" ") break ;;
        k) _cur=$(( (_cur + _n - 1) % _n )) ;;
        j) _cur=$(( (_cur + 1) % _n )) ;;
        [1-9]) [[ $_k -gt $_n ]] || _cur=$((_k - 1)) ;;
        $'\033')
          IFS= read -rsn2 -t 1 _rest || true
          case "$_rest" in
            "[A") _cur=$(( (_cur + _n - 1) % _n )) ;;
            "[B") _cur=$(( (_cur + 1) % _n )) ;;
          esac ;;
      esac
    done
    printf '\033[%dA\r\033[J\033[?25h' "$((_n + 2))" >&2
  else
    for ((_i = 0; _i < _n; _i++)); do
      if [[ -n "${_hints[$_i]}" ]]; then
        ui_bar "$(printf '%2d' $((_i + 1))). ${_labels[$_i]}  ${UI_DIM}${_hints[$_i]}${UI_OFF}"
      else
        ui_bar "$(printf '%2d' $((_i + 1))). ${_labels[$_i]}"
      fi
    done
    _def=$((_cur + 1)) _cur=""
    while [[ -z "$_cur" ]]; do
      ui_ask _ans "Pick one" "$_def" || ui_abort "Ran out of input at '$_q'"
      for ((_i = 0; _i < _n; _i++)); do
        if [[ "$_ans" == "${_keys[$_i]}" || "$_ans" == "$((_i + 1))" ]]; then
          _cur=$_i; break
        fi
      done
      [[ -n "$_cur" ]] || ui_warn "Pick a number from 1 to $_n"
    done
  fi
  ui_done "$_q" "${_labels[$_cur]}"
  UI_INDEX=$_cur
  printf -v "$_var" '%s' "${_keys[$_cur]}"
}
