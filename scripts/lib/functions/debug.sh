#!/bin/bash

#
#+ set_description < <(
#+    echo 'Print table of modules within the system.'
#+    echo -n "Fields: $(echo_coloured purple '`Name`'), "
#+    echo -n "$(echo_coloured purple '`Install-Path`'), "
#+    echo -n "$(echo_coloured purple '`Docker-Depends`'), "
#+    echo -n "$(echo_coloured purple '`Env-Depends`').")
#
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
           "${module_paths[$module]:--}" \
           "${module_docker_dependencies[$module]:--}" \
           "${module_env_dependencies[$module]:--}"
    done
  }

  print_table 'modules_iterator' "${titles[@]}"
}

#
#+ set_description < <(
#+    echo 'Print table of commands within the system.'
#+    echo -n "Fields: $(echo_coloured purple '`Command`'), "
#+    echo -n "$(echo_coloured purple '`Function`'), "
#+    echo -n "$(echo_coloured purple '`Options`'), "
#+    echo -n "$(echo_coloured purple '`Aliases`').")
#
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
