#!/usr/bin/env bash
set -eu -o pipefail

export PG_SERVICE="${DB_CLUSRER_NAME}-pgbouncer"


cat > ~/.pgpass <<EOF
*:*:${DB_NAME}:${DB_USER}:${DB_PW}
EOF
chmod 0600 ~/.pgpass
export PGPASSFILE=~/.pgpass

function pgo_client_is_ready() {
    kubectl -n pgo get pod -lname=pgo-client -ojson | jq '.items[].status | select(.containerStatuses != null) | .containerStatuses[] | select(.name=="pgo") | .ready' | grep --silent true
}

function wait_for_pgo_client_ready() {
    time_left=600
    until pgo_client_is_ready; do
        if [[ time_left -lt 0 ]]; then
        echo "pgo client not ready, timeout"
        exit 1
        fi
        time_left=$((time_left - 5))
        echo "waiting ${time_left} more for pgo client to become ready"
        sleep 5
    done
    echo "pgo client is ready"
}

function create_pgo_cluster() {
    local cluster_test_result
    cluster_test_result=$(kubectl -n pgo exec deploy/pgo-client -- pgo -n "${DB_NS}" test ${DB_CLUSRER_NAME})
    if [[ "${cluster_test_result}" != "Nothing found." ]]; then
        echo "Cluster ${DB_CLUSRER_NAME} already exists"
        exit 0;
    fi
    resources_args="" #--cpu=1.0 --cpu-limit=1.0 --memory=1Gi --memory-limit=1Gi

    kubectl -n pgo exec deploy/pgo-client -- pgo -n "${DB_NS}" create cluster ${DB_CLUSRER_NAME} \
        --replica-count=${PG_REPLICAS} --password-superuser="${DB_PW}" \
        --pgbouncer --pgbouncer-replicas=${PGBOUNCER_REPLICAS} --username=${DB_USER} --password=${DB_PW} \
        ${resources_args} --pod-anti-affinity=required --pod-anti-affinity-pgbouncer=preferred --pod-anti-affinity-pgbackrest=preferred --node-affinity-type=required --node-label=pool=pg_pool  --toleration=app=postgres:NoSchedule  \
        --metrics
    echo "Cluster ${DB_CLUSRER_NAME} created"
}

function is_db_ready() {
    pg_isready -h "${PG_SERVICE}" | grep --silent "accepting connections"
}

function check_db() {
    time_left=600
    until is_db_ready; do
        if [[ time_left -lt 0 ]]; then
        echo "DB not ready, quit..."
        exit 1
        fi
        time_left=$((time_left - 5))
        echo "waiting ${time_left} for DB"
        sleep 5
    done
    echo "db is ready"
}

wait_for_pgo_client_ready
create_pgo_cluster

check_db

for f in $DUMP_FILES; do
    echo "Processing ${f} file..."
    psql -h "${PG_SERVICE}" -U "${DB_USER}" "${DB_NAME}" < "${f}"
done