#!/bin/bash

#
#+ set_description < <(
#+   echo 'Initializes Laradock in existing laravel projects.')
#+ set_argument 1 project-name 'String' 'basename of APPLICATION' < <(
#+   echo 'Sets the project name.')
#+ set_argument rest modules 'String|Path' 'all builtin modules' < <(
#+   echo 'Modules to include within the output.')
#+ set_option e 'Path' './.laradock.example' < <(
#+   echo 'File path to sample Env example file to be generate.')
#+ set_option E 'Path' './.laradock' < <(
#+   echo 'File path to sample project-specific variables file to be generate.')
#+ set_option O 'Path' './.env' < <(
#+   echo 'Output Env file path to generate when the variables file is evaluated.')
#+ set_option y < <(
#+   echo 'Automatic yes to prompts. Assume "yes" as answer to all prompts and run non-interactively.')
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
