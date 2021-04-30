#!/bin/bash
set -x

kubectl create secret generic service-account-key --namespace=$1 --from-file=$GOOGLE_APPLICATION_CREDENTIALS
