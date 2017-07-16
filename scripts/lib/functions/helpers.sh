#!/bin/bash

error()
{
  echo "ERR: $@" 1>&2
}

ifelse()
{
  if [[ 0 -eq $? ]]; then
    echo "$1"
  else
    echo "$2"
  fi
}

foreach()
{
  local element
  for element in "${@:2}"; do
    "$1" "$element"
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

split()
{
  local -a elements

  OIFS=$IFS
  IFS=$1
  elements=(${@:2})
  IFS=$OIFS

  echo "${elements[@]}"
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
