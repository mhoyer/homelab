#!/bin/sh

set -e

talos_node="${1}"

if [ -z "${talos_node}" ]; then
  echo "Usage: ${0} <node>"
  exit 1
fi

./gen-config.sh "$talos_node"

case "${talos_node}" in
  x04)
    echo "\nApply initial control plane config to node ${talos_node}..."
    talosctl -n "${talos_node}" apply-config --insecure --file .generated/controlplane.yaml
    talosctl -n "${talos_node}" get members
    talosctl -n "${talos_node}" health
    echo "\nBootstrapping Kubernetes on control plane node ${talos_node}..."
    talosctl -n "${talos_node}" bootstrap
    talosctl -n "${talos_node}" kubeconfig
    ;;
  x01 | x02 | x03)
    echo "\nApply initial worker config to node ${talos_node}..."
    talosctl -n "${talos_node}" apply-config --insecure --file .generated/worker.yaml
    talosctl -n "${talos_node}" get members
    talosctl -n "${talos_node}" health
    echo "\nBootstrapping Kubernetes on worker node ${talos_node}..."
    talosctl -n "${talos_node}" bootstrap
    talosctl -n "${talos_node}" kubeconfig
    ;;
  *)
    echo "\nUnknown node: ${talos_node}"
    exit 1
    ;;
esac
