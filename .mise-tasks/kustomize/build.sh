#!/usr/bin/env bash

#MISE description="Build a kustomize overlay"
#MISE quiet=true

#USAGE arg "<dir>" help="Path to overlay"

set -euo pipefail
shopt -s nullglob

for tmpl in "${usage_dir?}"/*.env.tmpl; do
	fnox exec envsubst <"$tmpl" >"${tmpl%.tmpl}"
done
kustomize build --enable-helm "${usage_dir?}"
for tmpl in "${usage_dir?}"/*.env.tmpl; do
	rm "${tmpl%.tmpl}"
done
