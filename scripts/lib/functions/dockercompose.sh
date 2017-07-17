#!/bin/bash

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

  echo_dockercompose_path; echo -n ' '
  foreach echo_dockercompose_path ${included[@]:-${modules[@]}}
}
