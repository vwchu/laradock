#!/bin/bash
#
# Docker Entrypoint Script
#
# This script executes some commands on Docker container
# startup prior to the main command is executed.
#

#
# Ensure that the NPM packages for the current project are 
# installed. If the `node_modules` directory already exists and is not empty, 
# skips this step.
#
if [[ -e ./package.json ]] && [[ ! -d ./node_modules || -z "$(find ./node_modules -mindepth 1 -print -quit)" ]]; then
  if [[ "$NPM_NO_BIN_LINKS" == true ]]; then
    npm install --no-bin-links
  else
    npm install
  fi
fi

# Fix missing node-sass vendor bug
if [[ -d ./node_modules/node-sass && ! -d ./node_modules/node-sass/vendor ]]; then
  if [[ "$NPM_NO_BIN_LINKS" == true ]]; then
    npm rebuild node-sass --no-bin-links
  else
    npm rebuild node-sass
  fi
fi

# Execute the main command
exec "$@"
