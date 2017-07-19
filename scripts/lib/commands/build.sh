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
#= OPTION( 'd' 'Boolean' 'false' )
#=    Skip `docker-compose build`.
#= OPTION( 'y' )
#=    Automatic yes to prompts. Assume "yes" as answer to
#=    all prompts and run non-interactively.
#
on_build()
{
  local -A variables=( )
  local envexample="${options[e]:-$PWD/.laradock.example}"
  local envvars="${options[E]:-$PWD/.laradock}"
  local output="${options[O]}"

  evaluate < <(cat "$envvars" | to_load_script variables) 

  NOTTY="${options[y]}"
  MODULES="${variables[MODULES]}"
  ENV_FILE="${variables[ENV_FILE]}"

  output="${output:-$ENV_FILE}"
  output="${output:-$PWD/.env}"

  write_to_file "$output" make_env "$envexample" "$envvars" true true

  if [[ "${options[d]:-false}" == false ]]; then
    dockercompose build ${@}
  fi
}
