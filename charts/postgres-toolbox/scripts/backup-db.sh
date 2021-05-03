#!/usr/bin/env bash
# Backup postgresql DB and copy to GS

set -eu -o pipefail
set -x

file_name="${DB_NAME}-$(date +"%Y-%m-%d-%H-%M-%S")-dump.sql"

echo "Dump file ${file_name}"

pg_dump -h ${DB_NAME}-pgbouncer  -U ${DB_USER} ${DB_NAME} > ${file_name}
gsutil cp ${file_name} gs://${GS_BUCKET}
