#!/bin/bash

#
#+ set_description < <(
#+   echo 'Shows help for the CLI.')
#+ set_argument rest commands 'String' 'all' < <(
#+   echo 'Commands and command groups.')
#
on_help()
{
  [[ $# -eq 0 ]] && set "${commands[@]}"

  local -a print_queue=( )

  NO_SEPARATOR=true

  queue_print_job()
  {
    if ! $(contains "$1" "${print_queue[@]}"); then
      print_queue+=("$1")
    fi
  }

  print_command_help()
  {
    if [[ "${command_map[$1]}" == '['*']' ]]; then
      queue_print_job "$1"
      queue_print_job "$(resolve_aliased_command "$1")"
      return 0
    elif [[ -n "${command_map[$1]}" ]]; then
      queue_print_job "$1"
      return 0
    else
      return 1
    fi
  }

  for command in "$@"; do
    if $(contains "$command" "${command_groups[@]}"); then
      if [[ -n "${command_map[$command]}" ]]; then
        print_command_help "$command"
      fi
      for cmd in "${commands[@]}"; do
        if [[ "$cmd" == "${command}:"* ]]; then
          print_command_help "$cmd"
        fi
      done
    else
      print_command_help "$command"
      if [[ 0 -ne $? ]]; then
        error "unrecognized command: $command"
        foreach print_command_help "${commands[@]}"
      fi
    fi
  done

  foreach print_help "${print_queue[@]}"
}
