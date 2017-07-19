#!/bin/bash

#
#= DESCRIPTION
#=    Execute `docker-compose` with the given arguments.
#= OPTIONBREAK( 1 )
#= ARGUMENT( 'rest' 'arguments' 'String' )
#=    Arguments and options to forward to the `docker-compose` command.
#= OPTION( 'E' 'Path' './.env' )
#=    Environment variable file to extract module list.
#
on_dockercompose()
{
  local environ="${1:-$PWD/.env}"; source "$environ"
  
  dockercompose "$@"
}

#
#= DESCRIPTION
#=    Create and start containers. Execute `docker-compose up` with the given arguments.
#= OPTIONBREAK( 1 )
#= ARGUMENT( 'rest' 'arguments' 'String' )
#=    Arguments and options to forward to the `docker-compose` command.
#= OPTION( 'E' 'Path' './.env' )
#=    Environment variable file to extract module list.
#
on_up()
{
  on_dockercompose up "$@"
}

#
#= DESCRIPTION
#=    Stop and remove containers and networks, optionally volumes and images as well.
#=    Execute `docker-compose down` with the given arguments.
#= OPTIONBREAK( 1 )
#= ARGUMENT( 'rest' 'arguments' 'String' )
#=    Arguments and options to forward to the `docker-compose` command.
#= OPTION( 'E' 'Path' './.env' )
#=    Environment variable file to extract module list.
#
on_down()
{
  on_dockercompose down "$@"
}

#
#= DESCRIPTION
#=    Execute `docker-compose exec -it <container> bash` with the given arguments.
#= ARGUMENT( '1' 'container' 'String' )
#=    Docker container to attach a terminal to.
#= OPTIONBREAK( 2 )
#= ARGUMENT( 'rest' 'arguments' 'String' )
#=    Arguments and options to forward to the `docker-compose` command.
#=    Arguments before `--` are docker-compose options, after `--` are bash arguments.
#= OPTION( 'E' 'Path' './.env' )
#=    Environment variable file to extract module list.
#
on_tty()
{
  local is_dockeropts=true
  local -a dockeropts=( )
  local -a cmdargs=( )

  for arg in "${@:2}"; do
    if [[ "$is_dockeropts" == true ]]; then
      if [[ "$arg" == '--' ]]; then
        is_dockeropts=false
      else
        dockeropts+=("$arg")
      fi
    else
      cmdargs+=("$arg")
    fi
  done

  on_dockercompose exec "${dockeropts[@]}" "$1" bash "${cmdargs[@]}"
}
