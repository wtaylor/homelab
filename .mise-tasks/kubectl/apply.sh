#!/usr/bin/env bash

#MISE description="Build and apply a kustomize overlay to a cluster"

#USAGE arg "<dir>" help="Path to overlay"

set -euo pipefail

# Walk up from usage_dir to find .kubecontext (checks usage_dir itself first, then parents)
dir="$(realpath "${usage_dir?}")"
kubecontext_file=""
while [ "$dir" != "/" ]; do
	if [ -f "$dir/.kubecontext" ]; then
		kubecontext_file="$dir/.kubecontext"
		break
	fi
	dir="$(dirname "$dir")"
done
# Also check root
if [ -z "$kubecontext_file" ] && [ -f "/.kubecontext" ]; then
	kubecontext_file="/.kubecontext"
fi

if [ -z "$kubecontext_file" ]; then
	echo "Error: .kubecontext file not found in ${usage_dir?} or any parent up to /" >&2
	exit 1
fi

target_context="$(cat "$kubecontext_file")"
current_context="$(kubectl config current-context)"

cleanup() {
	kubectl config use-context "$current_context" >/dev/null 2>&1 || true
}
trap cleanup EXIT

kubectl config use-context "$target_context" >/dev/null
mise run kustomize:build "${usage_dir?}" | kubectl apply --server-side --force-conflicts -f -
