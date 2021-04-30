#!/bin/bash
# Script to generate postgresql passowrd file to avoid interactive ask

set -eu -o pipefail
set -x

cat > ~/.pgpass <<EOF
*:*:${DB_NAME}:${DB_USER}:${DB_PW}
EOF
chmod 0600 ~/.pgpass
export PGPASSFILE=~/.pgpass