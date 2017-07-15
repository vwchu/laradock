#!/bin/bash

_compose_option()
{
  echo -n " -f $1"
}

compose_paths()
{
  local compose_path="$1"

  if $(contains "$1" "${!all_modules[@]}"); then
    compose_path="$LARADOCK_ROOT/$1"
    if [[ -n "${all_modules[$1]}" ]]; then
      foreach compose_paths $(split ':' "${all_modules[$1]}")
    fi
  fi

  if [[ -f "${compose_path}/docker-compose.yml" ]]; then
    compose_path="${compose_path}/docker-compose.yml"
  elif [[ -f "${compose_path}.yml" ]]; then
    compose_path="${compose_path}.yml"
  fi

  if [[ -f "${compose_path}" ]]; then
    echo -n " ${compose_path}"
  else
    error "cannot find: ${compose_path}/docker-compose.yml"
    error "cannot find: ${compose_path}.yml"
    error "cannot find: ${compose_path}"
  fi
}

compose_options()
{
  foreach _compose_option $(compose_paths "$1")
}

output_dockercompose_list()
{
  compose_paths "$LARADOCK_ROOT"
  [[ $# -eq 0 || ${options[a]} ]] && foreach compose_paths "${!all_modules[@]}"
  foreach compose_paths "$@"
}

output_dockercompose_args()
{
  compose_options "$LARADOCK_ROOT"
  [[ $# -eq 0 || ${options[a]} ]] && foreach compose_options "${!all_modules[@]}"
  foreach compose_options "$@"
}
