#!/bin/bash

relative_filepath()
{
  # both $1 and $2 are absolute paths beginning with /
  # returns relative path to $2/$target from $1/$source
  local source="$([[ "$1" == /* ]]; ifelse "$1" "$PWD/$1")"
  local target="$([[ "$2" == /* ]]; ifelse "$2" "$PWD/$2")"
  local common_part="$source" # for now
  local result="" # for now

  while [[ "${target#$common_part}" == "${target}" ]]; do
    # no match, means that candidate common part is not correct
    # go up one level (reduce common part)
    common_part="$(dirname $common_part)"
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
      log note "unable to resolve filepath: $filepath"
    fi
  done

  log warn "unable to resolve '$2': $1"
  return 1
}

resolve_dockercompose_filepath()
{
  local root="$LARADOCK_INSTALL"
  if [[ "$1" == /* ]]; then
    resolve_filepath "$1" 'docker-compose.yml' %s/docker-compose.yml %s.yml
  else
    resolve_filepath "$1" 'docker-compose.yml' {$root/%s,%s}/docker-compose.yml %s.yml
  fi
}

resolve_envexample_filepath()
{
  local root="$LARADOCK_INSTALL"
  if [[ "$1" == /* ]]; then
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
  local response
  local filepath="$1"
  local shortened=$(relative_filepath "$PWD" "$filepath")

  if [[ -f "$filepath" ]]; then
    read -p "$(echo_coloured cyan "|> '$shortened' already exists, replace it? (yes/no): ")" response
    response="$(echo "$response" | tr '[[:upper:]]' '[[:lower:]]')"
    if [[ "$response" != 'yes' && "$response" != 'y' ]]; then
      log info "skipping: $shortened"
      return 1
    fi
  fi

  $2 "${@:3}" > "$1"
  ifok "Generated: $shortened" "Failed to generate: $shortened"
  return $?
}
