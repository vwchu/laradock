#!/bin/bash

declare -A all_modules=(
  ['workspace']=''
  ['php-fpm']='workspace'
  ['php-worker']='workspace'
  ['nginx']='php-fpm'
  ['blackfire']='php-fpm'
  ['apache2']='php-fpm'
  ['hhvm']='workspace'
  ['minio']=''
  ['mysql']=''
  ['percona']=''
  ['mssql']=''
  ['mariadb']=''
  ['postgres']=''
  ['postgres-postgis']='postgres'
  ['neo4j']=''
  ['mongo']=''
  ['rethinkdb']=''
  ['redis']=''
  ['aerospike']=''
  ['memcached']='php-fpm'
  ['beanstalkd']='php-fpm'
  ['rabbitmq']='php-fpm'
  ['beanstalkd-console']='beanstalkd'
  ['caddy']='php-fpm'
  ['phpmyadmin']=''
  ['adminer']='php-fpm'
  ['pgadmin']='postgres'
  ['elasticsearch']='php-fpm'
  ['kibana']='elasticsearch'
  ['certbot']=''
  ['mailhog']=''
  ['selenium']=''
  ['varnish']=''
  ['haproxy']='varnish'
  ['jenkins']=''
  ['laravel-echo-server']='redis'
)

declare -A command_map=(
)

declare -A command_opts=(
)

# A space delimited list of pairs of aliases.
# Each pair consists of the long form and its
# corresponding shorthand, separated by a colon.
declare -A option_aliases=(
)

# Number of columns (width) of the section dividers/headers
# to print into the generated environment variable
# configuration file.
readonly DIV_COLUMNS=60
