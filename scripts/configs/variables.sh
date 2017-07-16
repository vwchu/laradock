#!/bin/bash

# Array of all of the registered modules
# in the system. Loaded from `modules/*`.
declare -a modules=( )

# Mapping between all of the registered modules
# and its installation path in the filesystem.
# Loaded from `modules/*`.
declare -A module_path=( )

# Mapping between all of the registered modules
# and its docker-compose dependencies (comma-separated list).
# Loaded from `modules/*`.
declare -A module_docker_dependencies=( )

# Mapping between all of the registered modules
# and its env dependencies (comma-separated list).
# Loaded from `modules/*`.
declare -A module_env_dependencies=( )

# Mapping between a command and a function or
# alias for another command. Aliases have a
# square-bracketed value. (i.e.: "[cmd]")
declare -A command_map=( )

# Mapping between a command and its getopts
# option definition string value.
declare -A command_opts=( )

# A space delimited list of pairs of aliases.
# Each pair consists of the long form and its
# corresponding shorthand, separated by a colon.
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
