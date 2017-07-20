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

resolve_aliased_command()
{
  local cmd
  local -a aliases=( )

  if [[ "${command_map[$1]}" == '['*']' ]]; then
    resolve_aliased_command "$(echo "${command_map[$1]}" | sed -re 's/^\[(.*)\]$/\1/')"
  else
    for cmd in "${commands[@]}"; do
      if [[ "${command_map[$1]}" == "${command_map[$cmd]}" ]]; then
        aliases+=("$cmd")
      fi
    done
    if [[ "${#aliases[@]}" -gt 0 ]]; then
      aliases=("$(echo "${aliases[@]}" | sed -re 's/ /\n/g' | sort)")
    fi
    echo -n "${aliases[0]:-$1}"
  fi
}

list_command_aliases()
{
  local cmd
  local cmdalias="$(resolve_aliased_command "$1")"
  local -a aliases=( )

  for cmd in "${commands[@]}"; do
    if [[ "$1" == "$cmd" ]]; then
      continue
    elif [[ "$cmdalias" == "$(resolve_aliased_command "$cmd")" ]]; then
      aliases+=("$cmd")
    fi
  done

  echo -n "${aliases[@]}"
}

replace_option_aliases()
{
  local -A aliases=( )
  local -a shorten=( )
  local opt_aliases="$([[ -n "$COMMAND" ]]; ifelse "${option_aliases[$COMMAND]} ")${option_aliases['*']}"

  for pair in ${opt_aliases}; do
    aliases["${pair%\:*}"]="${pair#*\:}"
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
