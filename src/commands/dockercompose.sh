#!/bin/bash

#
#= DESCRIPTION
#=    Execute `docker-compose` with the given arguments.
#= OPTIONBREAK( 1 )
#= ARGUMENT( 'rest' 'arguments' 'String' )
#=    Arguments and options to forward to the `docker-compose` command.
#= OPTION( 'E' 'Path' './.env' )
#=    Environment variable file to extract module list.
#= OPTION( 'y' )
#=    Automatic yes to prompts. Assume "yes" as answer to
#=    all prompts and run non-interactively.
#
on_dockercompose()
{
  local -A variables=( )
  local environ="${options[E]:-$PWD/.env}"

  [[ -e "$environ" ]]; assert "Cannot find: $environ"

  evaluate < <(cat "$environ" | to_load_script variables) 

  NOTTY="${options[y]}"
  MODULES="${variables[MODULES]}"
  LOCAL_MODULES_PATH="${variables[LOCAL_MODULES_PATH]}"

  local -a function_args=($(cat "$environ" | get_env_metadata - ARGUMENTS))
  local checksum="$(cat "$environ" | get_env_metadata - SHA1)"
  local new_environ="$(make_env "${function_args[@]}")"
  local new_checksum="$(echo "$new_environ" | get_env_metadata - SHA1)"

  update_env()
  {
    log info "Checksums(original: $checksum, new: $new_checksum)"
    
    if [[ "$checksum" != "$new_checksum" ]]; then
      if [[ ! $NOTTY ]]; then
        read -p "$(echo_coloured cyan "|> '.env' has changed, update it? (yes/no): ")" response
        response="$(echo "$response" | tr '[[:upper:]]' '[[:lower:]]')"
        if [[ "$response" != 'yes' && "$response" != 'y' ]]; then
          log info "skipping update of '.env'"
          return 1
        fi
      fi
      NOTTY=true write_to_file "$environ" echo "$new_environ"
      log ok "|> May require rebuild to apply all changes: 'laradock build'."
    fi
    return 0
  }

  update_env
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
#= OPTION( 'y' )
#=    Automatic yes to prompts. Assume "yes" as answer to
#=    all prompts and run non-interactively.
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
#= OPTION( 'y' )
#=    Automatic yes to prompts. Assume "yes" as answer to
#=    all prompts and run non-interactively.
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
#= OPTION( 'y' )
#=    Automatic yes to prompts. Assume "yes" as answer to
#=    all prompts and run non-interactively.
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
