#!/bin/bash

compose_option()
{
  local compose_path="$1"

  if $(contains "$1" "${!all_modules[@]}"); then
    compose_path="$LARADOCK_ROOT/$1"
    if [[ -n "${all_modules[$1]}" ]]; then
      foreach compose_option $(split ':' "${all_modules[$1]}")
    fi
  fi

  if [[ -e "${compose_path}/docker-compose.yml" ]]; then
    echo -n " -f ${compose_path}/docker-compose.yml"
  fi
}

output_dockercompose_args()
{
  compose_option "$LARADOCK_ROOT"
  [[ $# -eq 0 || ${options[a]} ]] && foreach compose_option "${!all_modules[@]}"
  foreach compose_option "$@"
}
