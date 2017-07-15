#!/bin/bash

declare -a all_modules=(
  'workspace'
  'php-fpm'
  'php-worker'
  'nginx'
  'blackfire'
  'apache2'
  'hhvm'
  'minio'
  'mysql'
  'percona'
  'mssql'
  'mariadb'
  'postgres'
  'postgres-postgis'
  'neo4j'
  'mongo'
  'rethinkdb'
  'redis'
  'aerospike'
  'memcached'
  'beanstalkd'
  'rabbitmq'
  'beanstalkd-console'
  'caddy'
  'phpmyadmin'
  'adminer'
  'pgadmin'
  'elasticsearch'
  'kibana'
  'certbot'
  'mailhog'
  'selenium'
  'varnish'
  'haproxy'
  'jenkins'
  'laravel-echo-server'
)

declare -A command_map=(
  ['help']='display_help'
  ['environvars']='[environvars:template]'
  ['environvars:template']='output_environvars'
  ['environvars:evaluate']='output_processed_environvars'
  ['dockercompose']='[dockercompose:args]'
  ['dockercompose:args']='output_dockercompose_args'
)

declare -A command_opts=(
  ['environvars:template']=':o:a'
  ['environvars:evaluate']=':o:t:a'
  ['dockercompose:args']=':a'
)

# A space delimited list of pairs of aliases.
# Each pair consists of the long form and its
# corresponding shorthand, separated by a colon.
declare -A option_aliases=(
  ['environvars:template']="--output:-o --all:-a"
  ['environvars:evaluate']="--output:-o --all:-a --template:-t"
  ['dockercompose:args']='--all:-a'
)

# Number of columns (width) of the section dividers/headers
# to print into the generated environment variable
# configuration file.
readonly DIV_COLUMNS=60
