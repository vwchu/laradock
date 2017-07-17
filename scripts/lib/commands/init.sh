#!/bin/bash

on_init()
{
  local envexample_default="$PWD/.laradock.example"
  local envvars_default="$PWD/.laradock"

  local envexample="${options[e]:-$envexample_default}"
  local envvars="${options[E]:-$envvars_default}"
  local output="${options[O]}"
  local project_name="${1:-$(basename "$PWD")}"

  ENV_FILE="${output}"

  make_envexample "${@:2}" > "$envexample"
  make_envvars "$project_name" "${@:2}" > "$envvars"
}
