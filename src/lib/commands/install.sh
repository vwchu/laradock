#!/bin/bash

#
#= DESCRIPTION
#=    Installs this CLI at the given target path
#= ARGUMENT( '1' 'target' 'Path' './laradock' )
#=    Destination path to output the laradock executable script.
#= OPTION( 'y' )
#=    Automatic yes to prompts. Assume "yes" as answer to
#=    all prompts and run non-interactively.
#
on_install()
{
  local source="$CLI_PATH/$LARADOCK_CLI"
  local target="$(readlink -f -- "${1:-$PWD/laradock}")"

  NOTTY="${options[y]}"

  write_to_file "$target" make_linked_script "$target" "$source"
  if [[ $? -eq 0 ]]; then
    chmod +x "$target"
  fi
}
