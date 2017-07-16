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

echo_commands_info()
{
  local -a titles=(
    'Command'
    'Function'
    'Options'
    'Aliases'
  )

  commands_iterator()
  {
    for command in "${commands[@]}"; do
      "$1" "${command:--}" \
           "${command_map[$command]:--}" \
           "${command_opts[$command]:--}" \
           "${option_aliases[$command]:--}"
    done
  }

  print_table 'commands_iterator' "${titles[@]}"
}
