#!/usr/bin/env bash

#MISE description="Run an ansible playbook"

#USAGE arg "<dir>" help="Path to playbook"

set -euo pipefail

ansible-playbook -i ansible/common/inventory/ "${usage_dir?}"
