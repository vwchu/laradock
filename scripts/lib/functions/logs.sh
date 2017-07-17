#!/bin/bash

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
    local treshold="$(indexof note ${LOG_LEVELS[@]})"
    local datetime="$(date -uIseconds)"
    local header="$([[ $VERBOSE -ge $treshold ]]; ifelse "[$1 $datetime]: " "[$1]: " | awk '{print toupper($0)}')"
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

abort()
{
  log fatal "${@:2}"
  exit $1
}

ifok()
{
  local status=${3:-$?}
  if [[ 0 -eq $status ]]; then
    log ok "$1"
    return 0
  else
    error "$2"
    return 1
  fi
}

iferror()
{
  [[ 0 -ne $? ]] && error "$@"
}

assert()
{
  local status=$?
  if [[ 0 -ne $status ]]; then
    abort $status "$@"
  fi
}
