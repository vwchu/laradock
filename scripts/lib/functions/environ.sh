#!/bin/bash

make_envexample()
{
  local included=$(resolve_env_dependencies "$@")
  local root="$LARADOCK_INSTALL"

  resolve_envexample_filepath()
  {
    local filepath

    for fmt in {$root/%s,%s}{/,}.env.example %s; do
      filepath="$(printf "$fmt" "$1")"

      if [[ -f "$filepath" || -p "$filepath" ]]; then
        echo -n "$filepath"
        return 0
      else
        log note "unable to resolve filepath: $filepath"
      fi
    done

    log warn "unable to resolve '.env.example': $1"
    return 1
  }

  echo_envexample()
  {
    local transform=$([[ $noheader ]]; ifelse cat echo_divheader)

    for filepath in $(foreach resolve_envexample_filepath "$@"); do
      if [[ -r "$filepath" ]]; then
        cat "$filepath" | $transform | prepend_empty_line
      fi
    done
  }

  echo_header "General Setup"
  noheader=true echo_envexample ""
  noheader=true echo_envexample "misc"
  echo_header "Containers Customization"
  echo_envexample ${included[@]}
}
