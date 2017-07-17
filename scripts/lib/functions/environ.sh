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
# $3:   references to .env.vars with the variables specific to the project, colon-separated list
# $4:   environment variables to include during evaluation, colon-separated list
#
make_env()
{
  local include_extras=$1
  local envexample_path="$(resolve_envexample_filepath "$2")"
  local -a envvars_paths=($(split ':' "$3"))
  local -a import_vars=($(split ':' "$4"))
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

  import_variables()
  {
    local var

    for var in "$@"; do
      variables[$var]="$(echo "echo \"\$$var\"" | evaluate)"
    done
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
      import_variables "${import_vars[@]}"

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

#
# Generates a project specific .env.vars given project
# name and include modules. Outputs the generated .env to stdout.
# Sets the APPLICATION variable to the current working directory if not previously set.
# If project name is not given, defaults to basename of APPLICATION.
# If no modules given, defaults to include all modules
#
# $1:   project name, defaults to basename of APPLICATION.
# ..:   modules to include, defaults to include all modules
#
make_envvars()
{
  local template_path="$DATA_PATH/templates/envvars"
  local project_name="${1:-$(basename "$PWD")}"
  local -a included=("${@:2}")
  local -A variables=( )

  make_template()
  {
    echo_header "Project Specifics"
    noheader=true echo_envexample "$template_path"
    echo_header "Overrides"
  }

  populate_variables()
  {
    local app="${APPLICATION:-$PWD}"
    local name="${project_name:-$(basename "$app")}"
    local separator="${COMPOSE_PATH_SEPARATOR:-;}"

    variables["APPLICATION"]="$app"
    variables["COMPOSE_PROJECT_NAME"]="$name"
    variables["MODULES"]="${included[@]:-${modules[@]}}"
    variables["COMPOSE_PATH_SEPARATOR"]="$separator"
    variables["COMPOSE_FILE"]="$(list_dockercompose_files_with_separator "$separator" "${included[@]}")"
  }

  export_to_environment()
  {
    evaluate < <(for var in "${!variables[@]}"; do
      echo "$var=\"\${variables[$var]}\""
    done)
  }

  output_hints()
  {
    local -a keywords=( port user password database name path ip id token )

    {
      echo 'Here are some common variables to customize' | prepend_empty_line
      echo 'for your project to get your started.'
      echo 'See the Laradock documentation for more details.'

      make_envexample "$@" \
        | grep -v '^#' \
        | grep -iEv '(true|false)' \
        | grep -iE '^[^=]*('$(join '|' "${keywords[@]}")')=.*' \
        | prepend_empty_line \
        | append_empty_line

    } | sed -re 's/^/## /'
  }

  populate_variables
  export_to_environment
  make_template | make_env true /dev/stdin ':' "$(join ':' "${!variables[@]}")"
  output_hints "${included[@]}" | prepend_empty_line
}