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
#=    Execute `docker-compose up` with the given arguments.
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
