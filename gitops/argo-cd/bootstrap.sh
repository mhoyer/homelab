#!/bin/bash

ARGOCD_NAMESPACE="argo-cd"

helm upgrade --install \
  --create-namespace -n "${ARGOCD_NAMESPACE}" \
  argo-cd \
  oci://ghcr.io/argoproj/argo-helm/argo-cd \
  --version 8.1.3 \
  -f values.yaml

echo "Waiting for ArgoCD to be ready."
kubectl -n "${ARGOCD_NAMESPACE}" wait --for=condition=Ready --timeout=300s pod -l app.kubernetes.io/name=argocd-server

echo "Deploying self-referencing ArgoCD application."
kubectl apply -f argo-cd.app.yaml -n "${ARGOCD_NAMESPACE}"

ARGOCD_ADMIN_PASSWORD=$(kubectl -n "${ARGOCD_NAMESPACE}" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD is ready. Admin password: ${ARGOCD_ADMIN_PASSWORD}"

echo "Starting port-forward for ArgoCD server. Access it at https://localhost:8443"
kubectl port-forward service/argo-cd-argocd-server -n argo-cd 8443:443
