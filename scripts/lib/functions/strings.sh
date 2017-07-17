#!/bin/bash

trim()
{
  sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

remove_nonprintable()
{
  sed -e "s/\x1b\[.\{1,5\}m//g" \
    | sed -e "s/\x1b\[.//g" \
    | tr -d '[[:cntrl:]]' \
    | tr -cd '\11\12\15\40-\176'
}

prepend_empty_line()
{
  sed -e '1 i\ ' | sed -e '1 s/ //'
}

append_empty_line()
{
  sed -e '$ a\ ' | sed -e '$ s/ //'
}
