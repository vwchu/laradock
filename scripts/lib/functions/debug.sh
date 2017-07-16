#!/bin/bash

echo_modules_info()
{
  local -a titles=(
    'Name'
    'Install-Path'
    'Docker-Depends'
    'Env-Depends'
  )

  modules_iterator()
  {
    for module in "${modules[@]}"; do
      "$1" "${module:--}" \
           "${module_path[$module]:--}" \
           "${module_docker_dependencies[$module]:--}" \
           "${module_env_dependencies[$module]:--}"
    done
  }

  print_table 'modules_iterator' "${titles[@]}"
}
