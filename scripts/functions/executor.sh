#!/bin/bash

execute_command()
{
  if [[ -z "$COMMAND" ]]; then
    error "missing COMMAND, required argument"
    display_help | prepend_empty_line
  elif [[ -z "${command_map[$COMMAND]}" ]]; then
    error "unrecognized COMMAND '$COMMAND'"
    display_help | prepend_empty_line
  elif [[ "${command_map[$COMMAND]}" == '['*']' ]]; then
    COMMAND="${command_map[$COMMAND]#\[}"
    COMMAND="${COMMAND%\]}"
    execute_command
  else
    replace_option_aliases "${arguments[@]}"
    process_command_arguments "${arguments[@]}"
    "${command_map[$COMMAND]}" "${arguments[@]}"
  fi
}
