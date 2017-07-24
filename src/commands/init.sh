#!/bin/bash

#
#= DESCRIPTION
#=    Initializes Laradock into existing projects.
#= ARGUMENT( '1' 'project-name' 'String' 'basename of APPLICATION' )
#=    Sets the project name.
#= ARGUMENT( 'rest' 'modules' 'String|Path' 'all builtin modules' )
#=    Modules to include within the output.
#= OPTION( 'e' 'Path' './.laradock.example' )
#=    File path to sample Env example file to be generate.
#= OPTION( 'E' 'Path' './.laradock.env' )
#=    File path to sample project-specific variables file to be generate.
#= OPTION( 'O' 'Path' './.env' )
#=    Output Env file path to generate when the
#=    variables file is evaluated.
#= OPTION( 'L' )
#=    Install modules locally within the project.
#= OPTION( 'l' 'Path' './.laradock' )
#=    Path to local copy of modules, if '-L' provided.
#= OPTION( 'C' 'Boolean' 'false' )
#=    Create a linked Laradock CLI.
#= OPTION( 'c' 'Path' './laradock' )
#=    Path to linked Laradock CLI if '-C' provided.
#= OPTION( 'y' )
#=    Automatic yes to prompts. Assume "yes" as answer to
#=    all prompts and run non-interactively.
#
on_init()
{
  local envexample="${options[e]:-$PWD/.laradock.example}"
  local envvars="${options[E]:-$PWD/.laradock.env}"
  local modules_path="${options[l]:-$PWD/.laradock}"
  local output="${options[O]}"
  local project_name="${1:-$(basename "$PWD")}"

  ENV_FILE="${output}"
  NOTTY="${options[y]}"

  write_to_file "$envexample" make_envexample "${@:2}"
  write_to_file "$envvars" make_envvars "$project_name" "${@:2}"

  if [[ "${options[L]}" == true ]]; then
    on_install "$modules_path" "${@:2}"
    if [[ "${options[C]:-false}" == true ]]; then
      LOCAL_MODULES_PATH="$modules_path" NOTTY=true \
      write_to_file "$envvars" make_envvars "$project_name" "${@:2}"
    fi
  fi
}
