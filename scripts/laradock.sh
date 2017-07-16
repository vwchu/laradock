#!/bin/bash
#
# Laradock Shell CLI
#

readonly LARADOCK_ROOT="$(cd "$(dirname "$(readlink -f -- "$BASH_SOURCE")")/.."; pwd)"
readonly SCRIPTS_PATH="$LARADOCK_ROOT/scripts"

source "$SCRIPTS_PATH/configs/variables.sh"

#-----------------------------------------------------------
# Include Functions
#-----------------------------------------------------------

source "$SCRIPTS_PATH/functions/helpers.sh"
source "$SCRIPTS_PATH/functions/input.sh"
source "$SCRIPTS_PATH/functions/output.sh"
source "$SCRIPTS_PATH/functions/run.sh"

#-----------------------------------------------------------
# Include Commands
#-----------------------------------------------------------


#-----------------------------------------------------------
# Main
#-----------------------------------------------------------

main()
{
  process_arguments "$@"
  process_command
}

main "$@"
