#!/bin/bash

resolve_dependencies()
{
  local -a dependencies=("${@:2}")
  local -a queue=("${@:2}")
  local -i counter=0
  local idx depend newdepend

  while true; do
    counter=0
    for idx in "${!queue[@]}"; do
      depend="${queue[$idx]}"
      for newdepend in $(split ',' "$(source /dev/stdin < <(echo 'echo "${'$1'[$depend]}"'))"); do
        if [[ -n "$newdepend" ]] && ! $(contains "$newdepend" "${dependencies[@]}"); then
          dependencies+=("$newdepend")
          queue+=("$newdepend")
          let counter++
        fi
      done
      unset "queue[$idx]"
    done
    if [[ 0 -eq $counter ]]; then
      if [[ "${#queue[@]}" -gt 0 ]]; then
        error "unresolved dependencies: ${queue[@]}"
      fi
      echo "${dependencies[@]}"
      return
    fi
  done
}

resolve_docker_dependencies()
{
  resolve_dependencies module_docker_dependencies "$@"
}

resolve_env_dependencies()
{
  resolve_dependencies module_env_dependencies "$@"
}
