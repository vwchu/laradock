#!/bin/bash

run_command()
{
  if [[ -z "$COMMAND" ]]; then
    error "missing COMMAND, required argument"
  elif [[ -z "${command_map[$COMMAND]}" ]]; then
    error "unrecognized COMMAND '$COMMAND'"
  elif [[ "${command_map[$COMMAND]}" == '['*']' ]]; then
    COMMAND="${command_map[$COMMAND]#\[}"
    COMMAND="${COMMAND%\]}"
    process_command
  else
    replace_option_aliases "${arguments[@]}"
    process_command_arguments "${arguments[@]}"
    ${command_map[$COMMAND]#*\#} "${arguments[@]}"
  fi
}
