#!/bin/sh

set -e

if [ ! -f .secrets.yaml ]; then
  echo "\nGenerating .secrets.yaml"
  talosctl gen secrets --output-file .secrets.yaml
fi

talos_node="${1}"
talos_context="tatooine"
talos_endpoint="https://${talos_node}:6443"

if [ -z "${talos_node}" ]; then
  echo "Usage: ${0} <node>"
  exit 1
fi

mkdir -p ".generated"
echo "\nGenerating the configs from the merged patches and secrets"
talosctl gen config \
  --force \
  --with-secrets .secrets.yaml \
  --output .generated/ \
  --config-patch-control-plane @controlplane.patches.yaml \
  --config-patch-worker @worker.patches.yaml \
  "${talos_context}" "${talos_endpoint}"

echo "\nMoving the talosconfig to $HOME/.talos/config"
mkdir -p $HOME/.talos
mv .generated/talosconfig $HOME/.talos/config
talosctl config endpoint "${talos_node}"
