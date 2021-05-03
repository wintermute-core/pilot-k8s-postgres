#!/bin/bash
# Fetch container configuration

set -euxo pipefail
gcloud container clusters get-credentials $1 --zone $2 --project $3
