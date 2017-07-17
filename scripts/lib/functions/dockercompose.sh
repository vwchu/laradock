#!/bin/bash

resolve_dockercompose_filepath()
{
  local root="$LARADOCK_INSTALL"
  local filepath

  for fmt in {$root/%s,%s}/docker-compose.yml %s.yml; do
    filepath="$(printf "$fmt" "$1")"

    if [[ -f "$filepath" ]]; then
      echo -n "$filepath"
      return 0
    else
      log note "unable to resolve filepath: $filepath"
    fi
  done

  log warn "unable to resolve 'docker-compose.yml': $1"
  return 1
}

list_dockercompose_files()
{
  local with_opthandle=$1
  local included=$(resolve_docker_dependencies "${@:2}")

  echo_dockercompose_path()
  {
    local filepath="$(resolve_dockercompose_filepath "$1")"

    if [[ "$with_opthandle" == true ]]; then
      echo -n "-f $filepath"
    else
      echo -n "$filepath"
    fi
  }

  foreach echo_dockercompose_path ${included[@]}
}
