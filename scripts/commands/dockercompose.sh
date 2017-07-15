#!/bin/bash

echo_compose_option()
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

output_dockercompose_list_unfiltered()
{
  compose_paths "$LARADOCK_ROOT"
  [[ $# -eq 0 || ${options[a]} ]] && foreach compose_paths "${!all_modules[@]}"
  foreach compose_paths "$@"
}

output_dockercompose_list()
{
  distinct $(output_dockercompose_list_unfiltered "$@")
}

output_dockercompose_args()
{
  foreach echo_compose_option $(output_dockercompose_list "$@")
}
