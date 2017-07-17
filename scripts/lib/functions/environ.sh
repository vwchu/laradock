#!/bin/bash

#
# Makes an .env.example given a list of modules.
# Outputs the generated .env.example to stdout.
#
# ..:   references to the modules to include within the output.
#
make_envexample()
{
  local included=$(resolve_env_dependencies "$@")

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
  local -a envvars_paths=($(split ':' "$3"))
  local -a included=( )
  local -A variables=( )
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

  extras_envvars()
  {
    cat - | to_load_script variables \
          | (evaluate; find_extras) \
          | prepend_empty_line
  }

  evaluate_envvars()
  {
    local extras
    local envvars="$(echo_envvars "$@" | prepend_empty_line)"

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
