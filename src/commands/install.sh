#!/bin/bash

#
#= DESCRIPTION
#=    Install local copy of specific modules into the given directory path.
#= ARGUMENT( '1' 'destination' 'Path' './.laradock' )
#=    Destination to copy the modules and files to.
#= ARGUMENT( 'rest' 'modules' 'String' )
#=    Modules to include within the output.
#= OPTION( 'C' 'Boolean' 'false' )
#=    Create a linked Laradock CLI.
#= OPTION( 'c' 'Path' './laradock' )
#=    Path to linked Laradock CLI if '-C' provided.
#= OPTION( 'y' )
#=    Automatic yes to prompts. Assume "yes" as answer to
#=    all prompts and run non-interactively.
#
on_install()
{
  local root="$MODULES_PATH"
  local install_path="${1:-$PWD/.laradock}"
  local index_envexample="$(resolve_envexample_filepath)"
  local index_dockercompose="$(resolve_dockercompose_filepath)"
  local -a included_docker=($(resolve_docker_dependencies "${@:2}"))
  local -a included_environ=($(resolve_env_dependencies "${@:2}"))
  local -a included=($(distinct "${included_docker[@]}" "${included_environ[@]}"))
  local module

  NOTTY="${options[y]}"

  mkdir -p "$install_path"
  write_to_file "$install_path/$(basename "$index_envexample")"    cat "$index_envexample"
  write_to_file "$install_path/$(basename "$index_dockercompose")" cat "$index_dockercompose"

  for module in "${included[@]}"; do
    copy_directory "$root/${module_paths[$module]}" "$install_path/$module"
  done

  if [[ "${options[C]:-false}" == true ]]; then
    on_linkcli "${options[c]:-$PWD/laradock}" "$install_path"
  fi
}

#
#= DESCRIPTION
#=    Creates a link to this CLI at the given target path.
#= ARGUMENT( '1' 'target' 'Path' './laradock' )
#=    Destination path to output the laradock executable script.
#= ARGUMENT( '2' 'modules-path' 'Path' './.laradock' )
#=    Path to local copy of modules, if provided, sets MODULES_PATH variable.
#= OPTION( 'y' )
#=    Automatic yes to prompts. Assume "yes" as answer to
#=    all prompts and run non-interactively.
#
on_linkcli()
{
  local source="$CLI_PATH/$LARADOCK_CLI"
  local target="$(readlink -m -- "${1:-$PWD/laradock}")"
  local modules_path="${2:-$PWD/.laradock}"

  NOTTY="${options[y]}"

  write_to_file "$target" make_linked_script "$target" "$source"
  if [[ $? -eq 0 ]]; then
    chmod +x "$target"
    if [[ -n "$modules_path" ]]; then
      sed -i -- '/^BASEDIR=/ a\MODULES_PATH="'$(relative_filepath "$target" "$modules_path")'"' "$target"
    fi
  fi
}
