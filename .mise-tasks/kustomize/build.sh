#!/usr/bin/env bash

#MISE description="Build a kustomize overlay"
#MISE quiet=true

#USAGE arg "<dir>" help="Path to overlay"
#USAGE flag "-s --stub" help="Stub env files by copying .env.tmpl instead of resolving secrets with fnox"

set -euo pipefail
shopt -s nullglob

for tmpl in "${usage_dir?}"/*.env.tmpl; do
	if [[ -n "${usage_stub:-}" ]]; then
		cp "$tmpl" "${tmpl%.tmpl}"
	else
		fnox exec envsubst <"$tmpl" >"${tmpl%.tmpl}"
	fi
done
kustomize build --enable-helm "${usage_dir?}"
for tmpl in "${usage_dir?}"/*.env.tmpl; do
	rm "${tmpl%.tmpl}"
done
