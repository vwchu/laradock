#!/bin/bash

# Array of all of the registered modules
# in the system. Loaded from `modules/*`.
declare -a modules=( )

# Mapping between all of the registered modules
# and its installation path in the filesystem.
# Loaded from `modules/*`.
declare -A module_paths=( )

# Mapping between all of the registered modules
# and its docker-compose dependencies (comma-separated list).
# Loaded from `modules/*`.
declare -A module_docker_dependencies=( )

# Mapping between all of the registered modules
# and its env dependencies (comma-separated list).
# Loaded from `modules/*`.
declare -A module_env_dependencies=( )

# Array of all of the registered commands
# in the system. Loaded from `commands/*`
declare -a commands=( )

# Array of all of the registered grouping commands
# in the system. Loaded from `commands/*`.
# Signified by commands: <groupname>:<subcommand>.
declare -a command_groups=( )

# Mapping between a command and a function and 
# its source code filepath that contains that function,
# delimited by a hash '#' (i.e.: "filepath#function"),
# with filepath relative to SRC_PATH, or alias for
# another command. Aliases have a square-bracketed
# value. (i.e.: "[cmd]") Loaded from `commands/*`
declare -A command_map=( )

# Mapping between a command and its getopts
# option definition string value.
# Loaded from `commands/*`
declare -A command_opts=( )

# A space delimited list of pairs of aliases.
# Each pair consists of the long form and its
# corresponding shorthand, separated by a colon.
# Loaded from `commands/*`
declare -A option_aliases=( )

# Arrays of user-defined input arguments and
# specified options and corresponding values
declare -a arguments=( )
declare -A options=( )

# User specified command to execute
COMMAND=

# Number of columns (width) of the section dividers/headers
# to print into the generated environment variable
# configuration file.
readonly DIV_COLUMNS=60

# LIst of accepted log levels in the system
readonly -a LOG_LEVELS=(
  'silent'
  'ok'
  'fatal'
  'error'
  'warn'
  'note'
  'info'
  'verb'
)

# Mapping between verbose level and 
# output text colours to display to users.
readonly -A LOG_COLOURS=(
  ['fatal']='red'
  ['error']='lred'
  ['warn']='yellow'
  ['note']='orange'
  ['ok']='green'
  ['info']='blue'
  ['verb']='purple'
)

# Output file for log entries to be written to
LOG_FILE="${LOG_FILE:-}"

# Verbosity output level (0 through 7) [silent => verbose]
VERBOSE=${VERBOSE:-3}

# Flag to enable private developer commands
ENABLE_PRIVATE_COMMANDS=${ENABLE_PRIVATE_COMMANDS:-false}
