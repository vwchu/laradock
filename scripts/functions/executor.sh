#!/bin/bash

error_handler()
{
  error "$@"
  display_help | prepend_empty_line
}

execute_command()
{
  if [[ ${options[s]} ]]; then
    "${command_map[$COMMAND]}" "${arguments[@]}" 2> /dev/null
  else
    "${command_map[$COMMAND]}" "${arguments[@]}"
  fi
}

execute_command_wrapper()
{
  replace_option_aliases "${arguments[@]}"
  process_command_arguments "${arguments[@]}"
  if [[ ${options[h]} ]]; then
    display_help
  elif [[ ${options[v]} ]]; then
    display_version
  else
    "$@"
  fi
}

process_command()
{
  if [[ -z "$COMMAND" ]]; then
    execute_command_wrapper error_handler "missing COMMAND, required argument"
  elif [[ -z "${command_map[$COMMAND]}" ]]; then
    execute_command_wrapper error_handler "unrecognized COMMAND '$COMMAND'"
  elif [[ "${command_map[$COMMAND]}" == '['*']' ]]; then
    COMMAND="${command_map[$COMMAND]#\[}"
    COMMAND="${COMMAND%\]}"
    process_command
  else
    execute_command_wrapper execute_command
  fi
}
