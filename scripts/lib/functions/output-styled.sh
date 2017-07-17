#!/bin/bash

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
