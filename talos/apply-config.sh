#!/bin/sh

set -e

talos_node="${1}"

if [ -z "${talos_node}" ]; then
  echo "Usage: ${0} <node>"
  exit 1
fi

./gen-config.sh "${talos_node}"

case "${talos_node}" in
  x04)
    echo "\nApplying control plane configuration to node ${talos_node}..."
    talosctl -n "${talos_node}" apply-config -f .generated/controlplane.yaml
    ;;
  x01 | x02 | x03)
    echo "\nApplying worker configuration to node ${talos_node}..."
    talosctl -n "${talos_node}" apply-config -f .generated/worker.yaml
    ;;
  *)
    echo "Unknown node: ${talos_node}"
    exit 1
    ;;
esac
