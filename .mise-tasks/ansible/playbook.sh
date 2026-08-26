#!/usr/bin/env bash

set -eo pipefail

#MISE description="Run an ansible playbook"

#USAGE arg "<dir>" help="Path to overlay"

ansible-playbook -i ansible/common/inventory/ "${usage_dir?}"
