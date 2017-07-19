#!/bin/bash
#
#
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Greenplum
export GREENPLUM_HOST=greenplumsparkjdbc_gpdb_1
export GREENPLUM_USER=gpadmin
export GREENPLUM_DB=basic_db
export GREENPLUM_DB_PWD=pivotal
export PGPASSWORD=${GREENPLUM_DB_PWD}
