#!/bin/bash

ARGOCD_NAMESPACE="argo-cd"

helm upgrade --install \
  --create-namespace -n "${ARGOCD_NAMESPACE}" \
  --set crds.install="true" \
  argo-cd \
  oci://ghcr.io/argoproj/argo-helm/argo-cd \
  --version 8.1.3 \
  -f argo-cd/values.yaml

echo; echo "Waiting for ArgoCD to be ready."
kubectl -n "${ARGOCD_NAMESPACE}" wait --for=condition=Ready --timeout=300s pod -l app.kubernetes.io/name=argocd-server

ARGOCD_ADMIN_PASSWORD=$(kubectl -n "${ARGOCD_NAMESPACE}" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo; echo "✅ ArgoCD is ready. Admin password: ${ARGOCD_ADMIN_PASSWORD}"

echo; echo "Deploying self-referencing ArgoCD application in 5s."
sleep 5
kubectl apply -f argo-cd-appset/gitops.appset.yaml -n "${ARGOCD_NAMESPACE}"
echo "✅ done"

echo; echo "Starting port-forward for ArgoCD server. Access it at https://localhost:8443"
kubectl port-forward service/argo-cd-argocd-server -n argo-cd 8443:443
