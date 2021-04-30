#!/bin/bash
set -x
gcloud container clusters get-credentials $1 --zone $2 --project $3
