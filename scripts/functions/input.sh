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

replace_option_aliases()
{
  local -A aliases=( )
  local -a shorten=( )
  local opt_aliases="$([[ -n "$COMMAND" ]]; ifelse "${option_aliases[$COMMAND]} ")${option_aliases['*']}"

  for pair in ${opt_aliases}; do
    aliases["$(echo "$pair" | cut -f1 -d':')"]="$(echo "$pair" | cut -f2 -d':')"
  done

  for argv in "$@"; do
    shorten+=("$([[ -n "${aliases[$argv]}" ]]; ifelse "${aliases[$argv]}" "$argv")")
  done
  
  arguments=("${shorten[@]}")
}

process_command_arguments()
{
  local opts="$([[ -n "$COMMAND" ]]; ifelse "${command_opts[$COMMAND]}")${command_opts['*']}"

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
