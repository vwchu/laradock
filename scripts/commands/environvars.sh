#!/bin/bash

to_load_script()
{
  sed -re 's/^([^#=]*)=(.*)$/'$1'[\1]="\2"/'
}

to_output_script()
{
  sed -re 's/^([^#=]*)=.*$/\1=$\{'$1'[\1]\}/' \
       -e 's/`/\\`/g' \
       -e '/^#/ s/\$/\\$/g' \
       -e '1 i\cat - <<EOF' \
       -e '$ a\EOF'
}

echo_extras()
{
  local -A environvars=( )
  local -a included=($(split ' ' "${templatevars}"))

  cat "$@" | to_load_script environvars | (evaluate; {
    for var in ${!environvars[@]}; do
      if ! $(contains "$var" "${included[@]}"); then
        echo "${var}=${environvars[$var]}"
        included+=("$var")
      fi
    done
  } | prepend_empty_line)
}

list_environ_impl()
{
  local environ_path="$1"

  if $(contains "$1" "${!all_modules[@]}"); then
    environ_path="$LARADOCK_ROOT/$1"
    if [[ -n "${all_modules[$1]}" ]]; then
      foreach list_environ_impl $(split ':' "${all_modules[$1]}")
    fi
  fi

  if [[ -f "${environ_path}/.env.example" ]]; then
    environ_path="${environ_path}/.env.example"
  elif [[ -f "${environ_path}.env.example" ]]; then
    environ_path="${environ_path}.env.example"
  fi

  if [[ -f "${environ_path}" ]]; then
    echo -n " ${environ_path}"
  else
    error "cannot find: ${environ_path}/.env.example"
    error "cannot find: ${environ_path}.env.example"
    error "cannot find: ${environ_path}"
  fi
}

list_environ()
{
  distinct $(foreach list_environ_impl "$@")
}

echo_environ()
{
  local nodiv=$(test "$1" == '--nodiv'; ifelse true false)
  local transform=$($nodiv; ifelse cat echo_divheader); if $nodiv; then shift; fi
  
  for environ_path in $(list_environ "$@"); do
    cat "${environ_path}" | $transform | prepend_empty_line
  done
}

output_environvars()
{
  [[ $# -eq 0 || ${options[a]} ]] && set "${!all_modules[@]}" "$@"

  local index="$LARADOCK_ROOT"
  local output="${options[o]:-/dev/stdout}"

  ( # output
    echo_header "General Setup"
    echo_environ --nodiv "$index"
    echo_header "Containers Customization"
    echo_environ "$@"
    echo_header "Miscellaneous"
    echo_environ --nodiv "$index/misc"
  ) > "$output"
}

output_processed_environvars()
{
  local output="${options[o]:-/dev/stdout}"
  local -A environvars=( )
  local content

  if [[ -z "${options[t]}" ]]; then
    content="$(output_environvars)"
  elif [[ -f "${options[t]}" || -p "${options[t]}" ]]; then
    content="$(cat "${options[t]}")"
  elif [[ "${options[t]}" == *:* ]] || $(contains "${options[t]}" "${!all_modules[@]}"); then
    content="$(output_environvars $(split ':' "${options[t]}"))"
  fi

  if [[ $# -eq 0 ]]; then
    for name in '.laradock' '.env.example' '.env'; do
      if [[ -f "$PWD/$name" ]]; then
        set "$PWD/$name"
      fi
    done
  fi

  export templatevars="$(echo "$content" | to_load_script environvars | (evaluate; echo "${!environvars[@]}"))"

  (echo "$content"; cat "$@") | to_load_script environvars | (evaluate; {
    extras="$([[ $# -gt 0 && ${options[x]} ]] && echo_extras "$@")"
    extras="$([[ -n "$extras" ]] && (echo_header "Extras"; echo "$extras"))"
    (echo "$content"; echo "$extras") | to_output_script environvars | evaluate > "$output"
  })
}
