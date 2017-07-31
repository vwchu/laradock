#!/bin/bash

dockercompose()
{
  local -a dockeropts=($(list_dockercompose_files true "${MODULES[@]}"))

  log info "docker-compose ${dockeropts[@]} $@"
  docker-compose "${dockeropts[@]}" "$@"
}

#
#= DESCRIPTION
#=    List `docker-compose.yml` files required for the given modules.
#= ARGUMENT( '1' 'include-foption' 'Boolean' )
#=    Whether or not to include `-f` option in output.
#= ARGUMENT( 'rest' 'modules' 'String|Path' 'all builtin modules' )
#=    Modules to include within the output.
#
list_dockercompose_files()
{
  local with_opthandle=$1
  local included=$(resolve_docker_dependencies "${@:2}")

  echo_dockercompose_path()
  {
    local filepath="$(resolve_dockercompose_filepath "$1")"

    if [[ -n "$filepath" && "$with_opthandle" == true ]]; then
      echo -n "-f $filepath"
    else
      echo -n "$filepath"
    fi
  }

  echo_dockercompose_path; echo -n ' '
  foreach echo_dockercompose_path ${included[@]:-${modules[@]}}
}

#
#= DESCRIPTION
#=    List `docker-compose.yml` files required for the given modules.
#= ARGUMENT( '1' 'separator' 'String' )
#=    Separator to join files in list together.
#= ARGUMENT( 'rest' 'modules' 'String|Path' 'all builtin modules' )
#=    Modules to include within the output.
#
list_dockercompose_files_with_separator()
{
  list_dockercompose_files false "${@:2}" | trim | tr '[[:space:]]' "$1"
}
