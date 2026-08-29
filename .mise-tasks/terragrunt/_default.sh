#!/usr/bin/env bash

#MISE description="Terragrunt wrapper script that loads required secrets into environment"
#MISE raw=true
#MISE raw_args=true
#MISE dir="{{cwd}}"

fnox exec terragrunt "$@"
