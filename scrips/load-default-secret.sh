#!/bin/bash
# Upload current service account key as secret in K8S
set -euxo pipefail

kubectl create secret generic service-account-key --namespace=$1 --from-file=$GOOGLE_APPLICATION_CREDENTIALS
