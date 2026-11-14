#!/usr/bin/env bash

#MISE description="Archive a Paseo workspace"
#MISE quiet=true

#USAGE flag "--workspace-id <id>" help="Paseo workspace id" required=#true

set -euo pipefail

workspace_id="${usage_workspace_id?}"

if output="$(paseo workspace archive "${workspace_id}" --json 2>&1)"; then
	printf '%s\n' "${output}"
	exit 0
fi
if grep -q 'Workspace not found' <<<"${output}"; then
	echo "Workspace ${workspace_id} is already archived"
	exit 0
fi
printf '%s\n' "${output}" >&2
exit 1
