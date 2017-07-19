#!/bin/bash

#
#= DESCRIPTION
#=    Generate the necessary `.env` file to run docker-compose
#= ARGUMENT( 'rest' 'images' 'String' 'all included images' )
#=    Automatic run `docker-compose build` on the listed of Docker images.
#= OPTION( 'e' 'template-file' 'String|Path' './.laradock.example')
#=    Env example file to be used as the template.
#= OPTION( 'E' 'variable-file' 'String|Path' './.laradock')
#=    Env variables file with the variables specific to the project.
#= OPTION( 'O' 'Path' './.env' )
#=    Output Env file path to be generate.
#= OPTION( 'y' )
#=    Automatic yes to prompts. Assume "yes" as answer to
#=    all prompts and run non-interactively.
#
on_build()
{
  local envexample="${1:-$PWD/.laradock.example}"
  local envvars="${2:-$PWD/.laradock}"; source "$envvars"
  local dockerbuild="${options[D]}"
  local -a dockerimages=($(split ':' "${options[d]}"))
  local output="${options[O]:-$ENV_FILE}"

  NOTTY="${options[y]}"

  write_to_file "${output:-$PWD/.env}" make_env "$envexample" "$envvars" true true

  if [[ ${#dockerimages[@]} -gt 0 || $dockerbuild ]]; then
    dockercompose build ${dockerimages[@]}
  fi
}
