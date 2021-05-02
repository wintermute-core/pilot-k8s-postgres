#!/usr/bin/env bash
set -eu -o pipefail

function patch_tolerations_in_namespace() {
  local NAMESPACE="$1"

  pending_pods_owned_by_jobs=$(kubectl -n "${NAMESPACE}" get pods -o json | jq -r '.items[] | {name: .metadata.name, phase: .status.phase, ownerKind: .metadata.ownerReferences[0].kind, ownerName: .metadata.ownerReferences[0].name} | select(.phase == "Pending" and .ownerKind == "Job") | .name')

  replicasets_with_pending_pods=$(kubectl -n "${NAMESPACE}" get pods -o json | jq -r '.items[] | {name: .metadata.name, phase: .status.phase, ownerKind: .metadata.ownerReferences[0].kind, ownerName: .metadata.ownerReferences[0].name} | select(.phase == "Pending" and .ownerKind == "ReplicaSet") | .ownerName')

  date

  if [[ -n "$pending_pods_owned_by_jobs" ]]; then
    echo "Pending pods owned by jobs:"
    echo "$pending_pods_owned_by_jobs"
    echo ""

    for pod in $pending_pods_owned_by_jobs; do
      kubectl -n "${NAMESPACE}" patch pod $pod --patch "$(cat /scripts/tolerations-patch-pod.yaml)"
    done
    echo ""
  fi

  if [[ -n "$replicasets_with_pending_pods" ]]; then
    echo "ReplicaSets with pending pods:"
    echo "$replicasets_with_pending_pods"
    echo ""

    for rs in $replicasets_with_pending_pods; do
      deploy="${rs%-*}"
      kubectl -n "${NAMESPACE}" patch deployment $deploy --patch "$(cat /scripts/tolerations-patch-deployment.yaml)"
    done
    echo ""
  fi

  if [[ -z "$pending_pods_owned_by_jobs" && -z "$replicasets_with_pending_pods" ]]; then
    echo "No pending pods"
    echo ""
  fi
}

while true; do
  patch_tolerations_in_namespace "pgo"
  sleep 10
done
