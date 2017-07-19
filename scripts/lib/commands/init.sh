#!/bin/bash

#
#= DESCRIPTION
#=    Initializes Laradock in existing Laravel projects.
#= ARGUMENT( '1' 'project-name' 'String' 'basename of APPLICATION' )
#=    Sets the project name.
#= ARGUMENT( 'rest' 'modules' 'String|Path' 'all builtin modules' )
#=    Modules to include within the output.
#= OPTION( 'e' 'Path' './.laradock.example' )
#=    File path to sample Env example file to be generate.
#= OPTION( 'E' 'Path' './.laradock' )
#=    File path to sample project-specific variables file to be generate.
#= OPTION( 'O' 'Path' './.env' )
#=    Output Env file path to generate when the
#=    variables file is evaluated.
#= OPTION( 'y' )
#=    Automatic yes to prompts. Assume "yes" as answer to
#=    all prompts and run non-interactively.
#
on_init()
{
  local envexample_default="$PWD/.laradock.example"
  local envvars_default="$PWD/.laradock"

  local envexample="${options[e]:-$envexample_default}"
  local envvars="${options[E]:-$envvars_default}"
  local output="${options[O]}"
  local project_name="${1:-$(basename "$PWD")}"

  ENV_FILE="${output}"
  NOTTY="${options[y]}"

  write_to_file "$envexample" make_envexample "${@:2}"
  write_to_file "$envvars" make_envvars "$project_name" "${@:2}"
}
