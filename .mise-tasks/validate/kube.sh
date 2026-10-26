#!/usr/bin/env bash

#MISE description="Validate a kustomize project using kubeconform"

#USAGE flag "-a --all" help="Validate all overlays for all projects"
#USAGE arg "[dir]" help="Path to a single overlay"

set -euo pipefail
shopt -s nullglob

base_schema_location='https://scm.w7x6t.dev/yannh/kubernetes-json-schema/raw/branch/master/{{.NormalizedKubernetesVersion}}-standalone{{.StrictSuffix}}/{{.ResourceKind}}{{.KindSuffix}}.json'
crd_schema_location='https://scm.w7x6t.dev/datreeio/CRDs-catalog/raw/branch/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json'
kubeconform_flags=(-strict -summary -schema-location "$base_schema_location" -schema-location "$crd_schema_location" -skip "CustomResourceDefinition,VLSingle,VTSingle,VMSingle")

validate() {
	local dir="$1"
	echo "==> ${dir}"
	if [[ -f "${dir}/kustomization.yaml" || -f "${dir}/kustomization.yml" ]]; then
		mise run -q kustomize:build --stub "${dir}" | kubeconform "${kubeconform_flags[@]}"
	else
		kubeconform "${kubeconform_flags[@]}" "${dir}"
	fi
}

failures=0

if [[ -n "${usage_all:-}" ]]; then
	for dir in ./kubernetes/by-cluster/*/*/applications/by-namespace/*/*; do
		[[ -d "${dir}" ]] || continue
		validate "${dir}" || failures=$((failures + 1))
	done
elif [[ -n "${usage_dir:-}" ]]; then
	validate "${usage_dir}" || failures=$((failures + 1))
else
	echo "Error: provide a directory or pass --all" >&2
	exit 1
fi

if ((failures > 0)); then
	echo "Validation failed for ${failures} application(s)" >&2
	exit 1
fi
