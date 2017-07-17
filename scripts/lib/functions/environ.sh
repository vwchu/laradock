#!/bin/bash

resolve_envexample_filepath()
{
  local root="$LARADOCK_INSTALL"
  local filepath

  for fmt in {$root/%s,%s}{/,}.env.example %s; do
    filepath="$(printf "$fmt" "$1")"

    if [[ -f "$filepath" || -p "$filepath" ]]; then
      echo -n "$filepath"
      return 0
    else
      log note "unable to resolve filepath: $filepath"
    fi
  done

  log warn "unable to resolve '.env.example': $1"
  return 1
}

resolve_envvars_filepath()
{
  local filepath

  for fmt in %s/{.env.vars,.laradock,.env.laradock} %s; do
    filepath="$(printf "$fmt" "$1")"

    if [[ -f "$filepath" || -p "$filepath" ]]; then
      echo -n "$filepath"
      return 0
    else
      log note "unable to resolve filepath: $filepath"
    fi
  done

  log warn "unable to resolve '.env.vars': $1"
  return 1
}

#
# Makes an .env.example given a list of modules.
# Outputs the generated .env.example to stdout.
#
# ..:   references to the modules to include within the output.
#
make_envexample()
{
  local included=$(resolve_env_dependencies "$@")

  echo_envexample()
  {
    local transform=$([[ $noheader ]]; ifelse cat echo_divheader)

    for filepath in $(foreach resolve_envexample_filepath "$@"); do
      if [[ -r "$filepath" ]]; then
        cat "$filepath" | $transform | prepend_empty_line
      fi
    done
  }

  echo_header "General Setup"
  noheader=true echo_envexample ""
  noheader=true echo_envexample "misc"
  echo_header "Containers Customization"
  echo_envexample ${included[@]:-${modules[@]}}
}

#
# Evaluate the given an .env.example and list of .env.vars.
# Outputs the generated .env to stdout. Includes extras if
# specified as true.
#
# $1:   boolean whether or not to include extra variables
# $2:   reference to the .env.example to be used as the template
# ..:   references to .env.vars with the variables specific to the project
#
make_env()
{
  local include_extras=$1
  local envexample_path="$(resolve_envexample_filepath "$2")"
  local -a envvars_paths=("${@:3}")
  local -a included=( )
  local envexample

  to_load_script()
  {
    sed -re 's/^([^#=]*)=(.*)$/'$1'[\1]="\2"/'
  }
 
  to_output_script()
  {
    sed -re 's/^([^#=]*)=.*$/\1=$\{'$1'[\1]\}/' \
         -e 's/`/\\`/g' \
         -e '/^#/ s/\$/\\$/g' \
         -e '1 i\cat - <<EOF' \
         -e '$ a\EOF'
  }

  echo_envvars()
  {
    for filepath in $(foreach resolve_envvars_filepath "$@"); do
      if [[ -r "$filepath" ]]; then
        cat "$filepath"
      fi
    done
  }

  extras_envvars()
  {
    local -A variables=( )

    find_extras()
    {
      local var

      for var in "${!variables[@]}"; do
        if ! $(contains "$var" "${included[@]}"); then
          echo "${var}=${variables[$var]}"
          included+=("$var")
        fi
      done
    }

    cat - | to_load_script variables \
          | (evaluate; find_extras) \
          | prepend_empty_line
  }

  evaluate_envvars()
  {
    local extras
    local envvars="$(echo_envvars "$@" | prepend_empty_line)"
    local -A variables=( )

    included=($(echo "$envexample" | to_load_script variables | (evaluate; echo "${!variables[@]}")))

    (echo "$envexample$envvars") | to_load_script variables | (evaluate; {
      extras="$([[ $include_extras == true ]] && (echo "$envvars" | extras_envvars))"
      extras="$([[ -n "$extras" ]] && (echo_header "Extras" | prepend_empty_line; echo "$extras"))"
      (echo "$envexample$extras") | to_output_script variables | evaluate
    })
  }

  if [[ -r "$envexample_path" ]]; then
    envexample="$(cat "$envexample_path")"
    evaluate_envvars "${envvars_paths[@]}"
  else
    error "unable to open: $envexample_path"
  fi
}
