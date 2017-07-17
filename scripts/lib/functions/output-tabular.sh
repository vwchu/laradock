#!/bin/bash

print_table()
{
  local -a titles=("${@:2}")
  local -a fields=( )
  local iter="$1"
  local formatter

  update_field()
  {
    if [[ "${#2}" -gt "${fields[$1]}" ]]; then
      fields[$1]="${#2}"
    fi
  }

  update_fields()
  {
    local i
    for ((i = 1; i <= $#; i++)); do
      update_field $i "$(echo 'echo $'$i | source /dev/stdin)"
    done
  }

  make_formatter()
  {
    local i
    for ((i = 1; i <= ${#fields[@]}; i++)); do
      echo -n "%-${fields[$i]}s$([[ $i -lt ${#fields[@]} ]]; ifelse ' | ' "\\n")"
    done
  }

  print_record()
  {
    printf "$formatter" "$@"
  }

  table_header()
  {
    head -c $1 < /dev/zero | tr '\0' '-'
  }

  update_fields "${titles[@]}"
  $iter update_fields
  formatter="$(make_formatter)"

  set_cursor clear
  echo_styled -x bold echo_coloured -x purple print_record "${titles[@]}" | prepend_empty_line
  echo_coloured -x purple print_record $(foreach table_header "${fields[@]}")
  $iter print_record | append_empty_line
}
