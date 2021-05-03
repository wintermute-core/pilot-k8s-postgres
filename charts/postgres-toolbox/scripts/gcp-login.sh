#!/usr/bin/env bash
# Script to login to GCP using service account file

set -eu -o pipefail
set -x

gcloud auth activate-service-account --key-file /etc/google/security/*.json

