#!/bin/bash
#
# Laradock Shell CLI
#

readonly LARADOCK_CLI="$(basename "$BASH_SOURCE")"
readonly CLI_PATH="$(cd "$(dirname "$(readlink -f -- "$BASH_SOURCE")")"; pwd)"
readonly LARADOCK_INSTALL="$(readlink -f -- "$CLI_PATH/..")"
readonly LIB_PATH="$CLI_PATH/lib"
readonly DATA_PATH="$CLI_PATH/.data"

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

source "$LIB_PATH/commands/init.sh"

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
