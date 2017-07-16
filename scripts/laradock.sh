#!/bin/bash
#
# Laradock Shell CLI
#

readonly LARADOCK_CLI="$(cd "$(dirname "$(readlink -f -- "$BASH_SOURCE")")"; pwd)"
readonly LARADOCK_INSTALL="$LARADOCK_CLI/.."
readonly LIB_PATH="$LARADOCK_CLI/lib"
readonly DATA_PATH="$LARADOCK_CLI/.data"

source "$LIB_PATH/variables.sh"
source "$LIB_PATH/startup.sh"

#-----------------------------------------------------------
# Include Functions
#-----------------------------------------------------------

source "$LIB_PATH/functions/debug.sh"
source "$LIB_PATH/functions/depends.sh"
source "$LIB_PATH/functions/helpers.sh"
source "$LIB_PATH/functions/input.sh"
source "$LIB_PATH/functions/output.sh"
source "$LIB_PATH/functions/run.sh"

#-----------------------------------------------------------
# Include Commands
#-----------------------------------------------------------


#-----------------------------------------------------------
# Main
#-----------------------------------------------------------

main()
{
  boot
  process_arguments "$@"
  process_command
}

main "$@"
