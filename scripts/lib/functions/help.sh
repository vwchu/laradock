#!/bin/bash

compile_helpdocs()
{
  cat | awk -f "${LIB_PATH}/functions/help-compile.awk"
}

process_helpdocs()
{
  local docs="$(tac "${LIB_PATH}/${command_map[$1]%\#*}" \
                    | sed -n '/^'${command_map[$1]#*\#}'()$/,/^$/p' \
                    | sed -e '1d' -e '$d')"
  
  echo "$docs" | sed -re 's/^#\+[ ]?//' -e '/^#/d' | tac
  echo "$docs" | sed -re 's/^#\=[ ]?//' -e '/^#/d' | tac | compile_helpdocs
}

print_help()
{
  local command="${1:-$COMMAND}"
  local resolved_command="$(resolve_aliased_command "$command")"
  local description
  local -A colours=( [arg]='yellow' [opt]='cyan' [aliases]='gray' )
  local -A args=( )
  local -A opts=( )
  local -A attributes=( )

  set_description()
  {
    description="$(cat -)"
  }

  set_argument()
  {
    args[$1]="$2"
    attributes[arg:$1:type]="${3:-${attributes[arg:$1:type]}}"
    attributes[arg:$1:default]="$4"
    attributes[arg:$1:values]="$5"
    attributes[arg:$1:descript]="$(cat -)"
  }

  set_option()
  {
    attributes[opt:$1:type]="${2:-${attributes[opt:$1:type]}}"
    attributes[opt:$1:default]="$3"
    attributes[opt:$1:values]="$4"
    attributes[opt:$1:descript]="$(cat -)"
  }

  run_docs()
  {
    local src_file="${command_map[$resolved_command]%\#*}"
    local src_func="${command_map[$resolved_command]#*\#}"
    local docs="$(process_helpdocs "$resolved_command")"

    ifverb info echo -e "\r"
    log info -e "Docs[$(echo_coloured green "${src_file}#${src_func}")]:" \
                "\n$(echo_coloured gray "${docs}" | sed 's/^/  /')"

    evaluate < <(echo "$docs")
  }

  parse_options()
  {
    local lastch
    for ch in $(to_chars "${command_opts[$command]}"); do
      if [[ "$ch" == ':' && -n "$lastch" ]]; then
        attributes[opt:$lastch:type]="String"
      elif [[ "$ch" != ':' ]]; then
        opts[$ch]="$ch"
        attributes[opt:$ch:type]="Boolean"
      fi
      lastch="$ch"
    done
  }

  parse_option_aliases()
  {
    local opt aliasopt

    for pair in ${option_aliases[$command]}; do
      opt="${pair#*\:\-}"
      aliasopt="${pair%\:*}"

      if [[ -z "${attributes[opt:$opt:aliases]}" ]]; then
        opts[$opt]="${aliasopt#\-}"
        attributes[opt:$opt:aliases]="-$opt"
      else
        attributes[opt:$opt:aliases]+=", $aliasopt"
      fi

      if [[ "${attributes[opt:$opt:type]}" != 'Boolean' ]]; then
        attributes[opt:$opt:aliases]+=" <value>"
      fi
    done
  }

  print_argument()
  {
    if [[ -n "${args[$1]}" ]]; then
      echo_coloured ${colours[arg]} "${args[$1]}"
      echo_coloured ${colours[arg]} "$([[ -n "${attributes[arg:$1:values]}" ]]; ifelse "=${attributes[arg:$1:values]}" " (${attributes[arg:$1:type]})")"
      [[ -n "${attributes[arg:$1:default]}" ]] && echo_coloured ${colours[arg]} " (Default: ${attributes[arg:$1:default]})"
      echo -e "\n$(echo "${attributes[arg:$1:descript]}" | sed 's/^/  /')"
    fi
  }

  print_option()
  {
    echo_coloured ${colours[opt]} "-${opts[$1]}"
    echo_coloured ${colours[opt]} "$([[ -n "${attributes[opt:$1:values]}" ]]; ifelse "=${attributes[opt:$1:values]}" " (${attributes[opt:$1:type]})")"
    [[ -n "${attributes[opt:$1:default]}" ]] && echo_coloured ${colours[opt]} " (Default: ${attributes[opt:$1:default]})"
    echo -e "\n$(echo "${attributes[opt:$1:descript]}" | sed 's/^/  /')"
    echo_coloured ${colours[aliases]} -e "  aliases: ${attributes[opt:$1:aliases]}\n"
  }

  print_usage()
  {
    echo -n "$LARADOCK_CLI $command"
    if [[ ${#opts[@]} -gt 0 ]]; then echo_coloured ${colours[opt]} " <options...>"; fi
    if [[ ${#args[@]} -gt 0 ]]; then
      local idx
      for idx in {1..9} rest; do
        if [[ -n "${args[$idx]}" ]]; then
          echo_coloured ${colours[arg]} " <${args[$idx]}$([[ $idx == 'rest' ]]; ifelse '...')>"
        fi
      done
    fi
    if [[ "$resolved_command" != "$command" ]]; then
      echo -e "\n  Alias for: $(echo_coloured "${colours[aliases]}" "${resolved_command}")"
    else
      echo -e "\n$(echo "${description}" | sed 's/^/  /')"
    fi
  }

  print_aliases()
  {
    local -a aliases=($(list_command_aliases "$command"))
    if [[ "${#aliases[@]}" -gt 0 ]]; then
      echo_coloured ${colours[aliases]} -e "  aliases: $(join ', ' ${aliases[@]})\n"
    fi
  }

  parse_options
  parse_option_aliases
  run_docs

  print_usage | prepend_empty_line

  if [[ "$resolved_command" == "$command" ]]; then
    print_aliases
    NO_SEPARATOR=true foreach print_argument {1..9} rest | sed -e 's/^/    /'
    NO_SEPARATOR=true foreach print_option ${!opts[@]} | sed -e 's/^/    /'
  fi
}
