#!/bin/bash

load_modules()
{
  local name path docker_depends env_depends

  load_module()
  {
    modules+=("$name")
    module_path["$name"]="$path"
    module_docker_dependencies["$name"]="$docker_depends"
    module_env_dependencies["$name"]="${env_depends:-$docker_depends}"
  }

  source /dev/stdin < <(cat "$1" | awk -F ':' '{
    print "log info -ne \"Loading module: "$0"\\r\"";
    print "name=\""$1"\"";
    print "path=\""$2"\"";
    print "docker_depends=\""$3"\"";
    print "env_depends=\""$4"\"";
    print "load_module";
  }')
}

boot()
{
  loginit
  foreach load_modules ${DATA_PATH}/modules/*
  ifverb verb echo_modules_info
}
