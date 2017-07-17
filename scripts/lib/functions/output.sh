#!/bin/bash

trim()
{
  sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

remove_nonprintable()
{
  sed -e "s/\x1b\[.\{1,5\}m//g" \
    | sed -e "s/\x1b\[.//g" \
    | tr -d '[[:cntrl:]]' \
    | tr -cd '\11\12\15\40-\176'
}

prepend_empty_line()
{
  sed -e '1 i\ ' | sed -e '1 s/ //'
}

append_empty_line()
{
  sed -e '$ a\ ' | sed -e '$ s/ //'
}

### Env file output mechanisms

echo_divider()
{
  sed -e :a -e '1 s/^.\{1,'${1:-$DIV_COLUMNS}'\}$/&#/;ta'
}

echo_divheader()
{
  sed -e '1 s/^.*$/& /' | echo_divider
}

echo_header()
{
  echo '#' | echo_divider 30 | prepend_empty_line
  echo "# $@"
  echo '#' | echo_divider 30
}

### Coloured or styled output

set_colour()
{
  if [[ ! $NOTTY ]]; then
    case $1 in
      black)        echo -ne '\033[0;30m';;
      dgray)        echo -ne '\033[1;30m';;
      red)          echo -ne '\033[0;31m';;
      lred)         echo -ne '\033[1;31m';;
      green)        echo -ne '\033[0;32m';;
      lgreen)       echo -ne '\033[1;32m';;
      brown|orange) echo -ne '\033[0;33m';;
      yellow)       echo -ne '\033[1;33m';;
      blue)         echo -ne '\033[0;34m';;
      lblue)        echo -ne '\033[1;34m';;
      purple)       echo -ne '\033[0;35m';;
      lpurple)      echo -ne '\033[1;35m';;
      cyan)         echo -ne '\033[0;36m';;
      lcyan)        echo -ne '\033[1;36m';;
      lgray)        echo -ne '\033[0;37m';;
      white)        echo -ne '\033[1;37m';;
      none)         echo -ne '\033[0m';;
    esac
  fi
}

set_cursor()
{
  if [[ ! $NOTTY ]]; then
    tput "$@"
  fi
}

echo_coloured()
{
  if [[ "$1" == '-x' ]]; then 
    echo -n "$(set_colour $2)"; ${@:3}
    echo -n "$(set_colour none)"
  else
    echo -n "$(set_colour $1)"
    echo -n "${@:2}"
    echo -n "$(set_colour none)"
  fi
}

echo_styled()
{
  if [[ "$1" == '-x' ]]; then 
    echo -n "$(set_cursor $2)"; ${@:3}
    echo -n "$(set_cursor sgr0)"
  else
    echo -n "$(set_cursor $1)"
    echo -n "${@:2}"
    echo -n "$(set_cursor sgr0)"
  fi
}

print_table()
{
  local -a titles=("${@:2}")
  local -a fields=( )
  local iter="$1"
  local formatter

  update_field()
  {
    if [[ "${#2}" -gt "${fields[$1]}" ]]; then
      fields[$1]="${#2}"
    fi
  }

  update_fields()
  {
    local i
    for ((i = 1; i <= $#; i++)); do
      update_field $i "$(echo 'echo $'$i | source /dev/stdin)"
    done
  }

  make_formatter()
  {
    local i
    for ((i = 1; i <= ${#fields[@]}; i++)); do
      echo -n "%-${fields[$i]}s$([[ $i -lt ${#fields[@]} ]]; ifelse ' | ' "\\n")"
    done
  }

  print_record()
  {
    printf "$formatter" "$@"
  }

  table_header()
  {
    head -c $1 < /dev/zero | tr '\0' '-'
  }

  update_fields "${titles[@]}"
  $iter update_fields
  formatter="$(make_formatter)"

  set_cursor clear
  echo_styled -x bold echo_coloured -x purple print_record "${titles[@]}" | prepend_empty_line
  echo_coloured -x purple print_record $(foreach table_header "${fields[@]}")
  $iter print_record | append_empty_line
}

### Logging and error handling

loginit()
{
  if [[ -n "$LOG_FILE" ]]; then
    exec 3> "$LOG_FILE"
    exec 2>&3
  else
    exec 3>&2
  fi
}

ifverb()
{
  if [[ $VERBOSE -ge "$(indexof $1 ${LOG_LEVELS[@]})" ]]; then
    if [[ -n "$LOG_FILE" ]]; then
      NOTTY=true ${@:2} | remove_nonprintable >&3
    else
      ${@:2} >&3
    fi
  fi
}

log()
{
  if [[ $VERBOSE -ge "$(indexof $1 ${LOG_LEVELS[@]})" ]]; then
    local header="$(echo "[$1 $(date -uIseconds)]: " | awk '{print toupper($0)}')"
    if [[ -n "$LOG_FILE" ]]; then
      echo -n "${header}" >&3
      echo "${@:2}" >&3
    else
      set_cursor el >&3
      echo_coloured ${LOG_COLOURS[$1]} "${header}" >&3
      echo "${@:2}" >&3
    fi
  fi
}

error()
{
  log error "$@"
}
