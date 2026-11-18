#!/usr/bin/env bash
# bootstrap.sh — Skrip bootstrap untuk cluster Kubernetes lokal (kind / minikube)
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-__CLUSTER_NAME__}"
if [[ "$CLUSTER_NAME" == "__CLUSTER_NAME__" ]]; then
  CLUSTER_NAME="saas-gitops-local"
fi

echo "[1/5] Memeriksa prasyarat..."
for cmd in kubectl; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: $cmd belum terpasang." >&2
    exit 1
  fi
done

echo "[2/5] Memvalidasi render Kustomize untuk namespace & mock add-ons lokal (infra/local)..."
kubectl kustomize infra/local > /dev/null

echo "[3/5] Memvalidasi render Kustomize untuk observability stack (platform-configs/observability)..."
kubectl kustomize platform-configs/observability > /dev/null

echo "[4/5] Memvalidasi render Kustomize untuk Argo CD AppProject, RBAC, dan ApplicationSet..."
kubectl kustomize platform-configs > /dev/null

echo "[5/5] Memvalidasi overlay Kustomize untuk base, tier basic, dan tier pro..."
kubectl kustomize workloads/base > /dev/null
kubectl kustomize workloads/overlays/basic > /dev/null
kubectl kustomize workloads/overlays/pro > /dev/null

echo "Bootstrap validasi selesai untuk cluster: ${CLUSTER_NAME}"
echo "Untuk menerapkan ke cluster aktif, jalankan:"
echo "  kubectl apply -k infra/local"
echo "  kubectl apply -k platform-configs/observability"
echo "  kubectl apply -k platform-configs"
