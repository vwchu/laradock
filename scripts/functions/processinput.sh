#!/bin/bash

process_arguments()
{
  while [[ $# -gt 0 ]]; do
    if [[ "$1" != -* && -z "$COMMAND" ]]; then
      COMMAND="$1"
    else
      arguments+=( "$1" )
    fi
    shift
  done
}

replace_option_aliases_impl()
{
  local -A aliases=( )
  local -a shorten=( )

  for pair in ${opt_aliases}; do
    aliases["$(echo "$pair" | cut -f1 -d':')"]="$(echo "$pair" | cut -f2 -d':')"
  done

  for argv in "$@"; do
    if [[ -n "${aliases[$argv]}" ]]; then
      shorten+=("${aliases[$argv]}")
    else
      shorten+=("$argv")
    fi
  done
  
  arguments=("${shorten[@]}")
}

process_command_arguments_impl()
{
  while getopts "${opts}" opt; do
    case $opt in
      \?) error "invalid option '-$OPTARG'";;
      :)  error "option -$OPTARG requires an argument";;
      *)  options["$opt"]="${OPTARG:-true}";;
    esac
  done
  shift $((OPTIND-1))
  arguments=("$@")
}

replace_option_aliases()
{
  export opt_aliases="$([[ -n "$COMMAND" ]]; ifelse "${option_aliases[$COMMAND]} ")${option_aliases['*']}"

  replace_option_aliases_impl "$@"
}

process_command_arguments()
{
  export opts="$([[ -n "$COMMAND" ]]; ifelse "${command_opts[$COMMAND]}")${command_opts['*']}"

  process_command_arguments_impl "$@"
}
