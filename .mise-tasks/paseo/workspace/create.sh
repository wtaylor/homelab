#!/usr/bin/env bash

#MISE description="Create a Paseo workspace for an issue"
#MISE quiet=true

#USAGE flag "--project <id>" help="Paseo project id (defaults to PASEO_PROJECT)"
#USAGE flag "--new-branch <name>" help="Branch to create in the workspace" required=#true
#USAGE flag "--base <ref>" help="Base ref to branch from" default="origin/main"
#USAGE flag "--title <title>" help="Workspace title" required=#true

set -euo pipefail

project="${usage_project:-${PASEO_PROJECT:-}}"
if [[ -z "${project}" ]]; then
	echo "Error: no Paseo project id; pass --project or set PASEO_PROJECT" >&2
	exit 1
fi

workspace_id="$(
	paseo workspace create \
		--isolation worktree \
		--project "${project}" \
		--mode branch-off \
		--new-branch "${usage_new_branch?}" \
		--base "${usage_base?}" \
		--title "${usage_title?}" \
		-o json | jq -er '.workspaceId'
)"

printf '%s\n' "${workspace_id}"
