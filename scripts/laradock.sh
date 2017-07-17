#!/bin/bash
#
# Laradock Shell CLI
#

readonly LARADOCK_CLI="$(cd "$(dirname "$(readlink -f -- "$BASH_SOURCE")")"; pwd)"
readonly LARADOCK_INSTALL="$(readlink -f -- "$LARADOCK_CLI/..")"
readonly LIB_PATH="$LARADOCK_CLI/lib"
readonly DATA_PATH="$LARADOCK_CLI/.data"

source "$LIB_PATH/variables.sh"
source "$LIB_PATH/startup.sh"

#-----------------------------------------------------------
# Include Functions
#-----------------------------------------------------------

source "$LIB_PATH/functions/debug.sh"
source "$LIB_PATH/functions/depends.sh"
source "$LIB_PATH/functions/dockercompose.sh"
source "$LIB_PATH/functions/environ.sh"
source "$LIB_PATH/functions/files.sh"
source "$LIB_PATH/functions/helpers.sh"
source "$LIB_PATH/functions/input.sh"
source "$LIB_PATH/functions/logs.sh"
source "$LIB_PATH/functions/output-environ.sh"
source "$LIB_PATH/functions/output-styled.sh"
source "$LIB_PATH/functions/output-tabular.sh"
source "$LIB_PATH/functions/run.sh"
source "$LIB_PATH/functions/strings.sh"

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
  run_command
}

main "$@"
