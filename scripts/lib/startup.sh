#!/bin/bash

mkloader()
{
  local log_message="$1"
  local load_func="$2"
  local -a attributes=("${@:3}")

  assign_attribute()
  {
    echo -n 'print "'${attributes[$1]}'=\""$'$(($1+1))'"\"";'
  }

  echo -n '{print "log info -ne \"'$log_message': "$0"\\r\"";'
  foreach assign_attribute "${!attributes[@]}"
  echo -n 'print "'$load_func'";}'
}

load_modules()
{
  local name path docker_depends env_depends
  local loader="$(mkloader 'Loading module' 'load_module' name path docker_depends env_depends)"

  load_module()
  {
    modules+=("$name")
    module_path["$name"]="$path"
    module_docker_dependencies["$name"]="$docker_depends"
    module_env_dependencies["$name"]="${env_depends:-$docker_depends}"
  }

  source /dev/stdin < <(cat "$1" | awk -F ',' "$loader")
}

boot()
{
  loginit
  foreach load_modules ${DATA_PATH}/modules/builtins
  ifverb verb echo_modules_info
  ifverb info echo
}
