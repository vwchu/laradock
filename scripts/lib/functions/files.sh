#!/bin/bash

resolve_filepath()
{
  local filepath

  for fmt in "${@:3}"; do
    filepath="$(printf "$fmt" "$1")"

    if [[ -f "$filepath" || -p "$filepath" ]]; then
      echo -n "$(readlink -f -- "$filepath")"
      return 0
    else
      log note "unable to resolve filepath: $filepath"
    fi
  done

  log warn "unable to resolve '$2': $1"
  return 1
}

resolve_dockercompose_filepath()
{
  local root="$LARADOCK_INSTALL"

  resolve_filepath "$1" 'docker-compose.yml' {$root/%s,%s}/docker-compose.yml %s.yml
}

resolve_envexample_filepath()
{
  local root="$LARADOCK_INSTALL"

  resolve_filepath "$1" '.env.example' {$root/%s,%s}{/,}{.env,.laradock}.example %s
}

resolve_envvars_filepath()
{
  resolve_filepath "$1" '.env.vars' %s{/,}{.env.vars,.laradock,.env.laradock} %s
}
