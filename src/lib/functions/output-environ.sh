#!/bin/bash

echo_divider()
{
  sed -e :a -e '1 s/^.\{1,'${1:-$DIV_COLUMNS}'\}$/&#/;ta'
}

echo_divheader()
{
  sed -e '1 s/^.*$/& /' | echo_divider
}

echo_header()
{
  echo '#' | echo_divider 30 | prepend_empty_line
  echo "# $@"
  echo '#' | echo_divider 30
}

echo_envexample()
{
  local transform=$([[ $noheader ]]; ifelse cat echo_divheader)

  for filepath in $(foreach resolve_envexample_filepath "$@"); do
    if [[ -r "$filepath" ]]; then
      cat "$filepath" | $transform | prepend_empty_line
    fi
  done
}

echo_envvars()
{
  for filepath in $(foreach resolve_envvars_filepath "$@"); do
    if [[ -r "$filepath" ]]; then
      cat "$filepath"
    fi
  done
}
