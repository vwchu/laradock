#!/bin/bash

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
  local i
  local -a elements=("${@:2}")
  for ((i = 0; i < "${#elements[@]}"; i++)); do
    [[ $i -gt 0 ]] && echo -n "${SEPARATOR:- }"
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
