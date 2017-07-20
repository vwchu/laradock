#!/bin/bash

ifelse()
{
  local status=${3:-$?}
  if [[ 0 -eq $status ]]; then
    echo "$1"
  else
    echo "$2"
  fi
}

foreach()
{
  local i
  local -a elements=("${@:2}")
  for ((i = 0; i < "${#elements[@]}"; i++)); do
    [[ ! $NO_SEPARATOR && $i -gt 0 ]] && echo -n "${SEPARATOR:- }"
    "$1" "${elements[$i]}"
  done
}

contains()
{
  local element
  for element in "${@:2}"; do
    [[ "$element" == "$1" ]] && return 0
  done
  return 1
}

indexof()
{
  local i
  local -a array=("${@:2}")
  for ((i = 0; i < "${#array[@]}"; i++)); do
    if [[ "${array[$i]}" == "$1" ]]; then
      echo $i
      return
    fi
  done
  echo -1
}

split()
{
  local -a elements

  OIFS=$IFS
  IFS=$1
  elements=(${@:2})
  IFS=$OIFS

  echo "${elements[@]}"
}

join()
{
  local delim="$1"
  local first="$2"
  local -a rest=("${@:3}")

  echo -n "$first"
  printf "%s" "${rest[@]/#/$delim}"
}

distinct()
{
  local element
  local -a uniques=( )

  for element in "$@"; do
    if ! $(contains "$element" "${uniques[@]}"); then
      uniques+=("$element")
    fi
  done

  echo -n "${uniques[@]}"
}

evaluate()
{
  source /dev/stdin
}

os_type()
{
  case "$OSTYPE" in
    solaris*) echo "SOLARIS" ;;
    darwin*)  echo "OSX" ;;
    linux*)   echo "LINUX" ;;
    bsd*)     echo "BSD" ;;
    freebsd*) echo "FREEBSD" ;;
    cygwin)   echo "WINDOWS" ;;
    msys*)    echo "WINDOWS" ;;
    win32)    echo "WINDOWS" ;; # It could happen... someday. :-)
    *)        error "unknown system type: $OSTYPE" ;;
  esac
}

make_linked_script()
{
  local script_template="$CONFIG_PATH/templates/linked_script"
  local source_path="$(relative_filepath "$(dirname "$1")" "$2")"

  cat "$script_template" | sed -re 's|[$]SOURCE|'"$source_path"'|g'
}
