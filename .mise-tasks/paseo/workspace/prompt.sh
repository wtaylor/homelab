#!/usr/bin/env bash

#MISE description="Start a Paseo agent with a prompt"
#MISE quiet=true

#USAGE flag "--workspace-id <id>" help="Paseo workspace id" required=#true
#USAGE flag "--title <title>" help="Agent title"
#USAGE arg "<prompt>" help="Prompt to send to the agent"

set -euo pipefail

provider="omp"
model="openrouter/deepseek/deepseek-v4.1-flash-1017"

args=(
	run
	--workspace "${usage_workspace_id?}"
	--provider "${provider}"
	--model "${model}"
	--no-wait
)
if [[ -n "${usage_title:-}" ]]; then
	args+=(--title "${usage_title}")
fi
args+=("${usage_prompt?}")

paseo "${args[@]}"
