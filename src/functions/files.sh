#!/bin/bash

relative_filepath()
{
  # both $1 and $2 are absolute paths beginning with /
  # returns relative path to $2/$target from $1/$source
  local source="$(readlink -m -- "$1")"
  local target="$(readlink -m -- "$2")"
  local common_part="$source" # for now
  local result="" # for now

  [[ -n "$source" ]]; assert "Source path cannot be empty string."
  [[ -n "$target" ]]; assert "Target path cannot be empty string."

  while [[ "${target#$common_part}" == "${target}" && "$common_part" != "/" ]]; do
    # no match, means that candidate common part is not correct
    # go up one level (reduce common part)
    common_part="$(dirname "$common_part")"
    # and record that we went back, with correct / handling
    if [[ -z $result ]]; then
      result=".."
    else
      result="../$result"
    fi
  done

  if [[ $common_part == "/" ]]; then
    result="$result/" # special case for root (no common path)
  fi

  # since we now have identified the common part,
  # compute the non-common part
  forward_part="${target#$common_part}"

  # and now stick all parts together
  if [[ -n $result ]] && [[ -n $forward_part ]]; then
    result="$result$forward_part"
  elif [[ -n $forward_part ]]; then
    result="${forward_part:1}" # extra slash removal
  fi

  echo $result
}

resolve_filepath()
{
  local filepath

  for fmt in "${@:3}"; do
    filepath="$(printf "$fmt" "$1")"

    if [[ -f "$filepath" ]]; then
      echo -n "$(readlink -f -- "$filepath")"
      return 0
    elif [[ -p "$filepath" ]]; then
      echo -n "$filepath"
      return 0
    else
      log verb "unable to resolve filepath: $filepath"
    fi
  done

  log warn "unable to resolve '$2': $1"
  return 1
}

resolve_dockercompose_filepath()
{
  local root="${LOCAL_MODULES_PATH:-$MODULES_PATH}"
  if $(contains "$1" "${modules[@]}"); then
    resolve_filepath "$1" 'docker-compose.yml' "$root/${module_paths[$1]}/docker-compose.yml"
  elif [[ "$1" == /* ]]; then
    resolve_filepath "$1" 'docker-compose.yml' %s/docker-compose.yml %s.yml
  else
    resolve_filepath "$1" 'docker-compose.yml' {$root/%s,%s}/docker-compose.yml %s.yml
  fi
}

resolve_envexample_filepath()
{
  local root="${LOCAL_MODULES_PATH:-$MODULES_PATH}"
  if $(contains "$1" "${modules[@]}"); then
    resolve_filepath "$1" '.env.example' "$root/${module_paths[$1]}/"{.env,.laradock}.example
  elif [[ "$1" == /* ]]; then
    resolve_filepath "$1" '.env.example' %s{/,}{.env,.laradock}.example %s
  else
    resolve_filepath "$1" '.env.example' {$root/%s,%s}{/,}{.env,.laradock}.example %s
  fi
}

resolve_envvars_filepath()
{
  resolve_filepath "$1" '.env.vars' %s{/,}{.env.vars,.laradock,.env.laradock} %s
}

write_to_file()
{
  local response ret
  local filepath="$1"
  local shortened=$(relative_filepath "$PWD" "$filepath")

  if [[ ! $NOTTY && -f "$filepath" ]]; then
    read -p "$(echo_coloured cyan "|> '$shortened' already exists, replace it? (yes/no): ")" response
    response="$(echo "$response" | tr '[[:upper:]]' '[[:lower:]]')"
    if [[ "$response" != 'yes' && "$response" != 'y' ]]; then
      log info "skipping: $shortened"
      return 1
    fi
  fi

  mkdir -pv "$(dirname "$filepath")" | writelog info
  assert "Cannot create directory: $(dirname "$filepath")"

  $2 "${@:3}" > "$filepath"; ret=$?

  log info "Command: $2 ${@:3} > $filepath"
  ifok "Generated: $shortened" "Failed to generate: $shortened" $ret

  ifverb info echo -e "\r"
  log info -e "File[$(echo_coloured green "$1")]:" \
              "\n$(echo_coloured yellow "Command: $2 ${@:3}" | sed 's/^/  /')" \
              "\n$(echo_coloured gray "$(cat "$1")" | sed 's/^/    > /')"

  return $ret
}

copy_directory()
{
  local response ret
  local source_path="$1"
  local target_path="$2"
  local source_short=$(relative_filepath "$PWD" "$source_path")
  local target_short=$(relative_filepath "$PWD" "$target_path")

  [[ -d "$source_path" ]]; assert "Cannot find directory: $source_short"

  if [[ -d "$target_short" ]]; then
    if [[ ! $NOTTY ]]; then
      read -p "$(echo_coloured cyan "|> Directory '$target_short' already exists, replace it? (yes/no): ")" response
      if [[ "$response" != 'yes' && "$response" != 'y' ]]; then
        log info "skipping: $target_short"
        return 1
      fi
    fi
  else
    mkdir -pv "$target_path" | writelog info
    assert "Cannot create directory: $target_short"
  fi

  cp -RTv "$source_path" "$target_path" | writelog info
  ifok "Copied: $source_short => $target_short" \
       "Failed to copy: $source_short => $target_short"; ret=$?

  return $ret
}
