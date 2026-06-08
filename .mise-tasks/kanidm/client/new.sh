#!/usr/bin/env bash

set -eo pipefail

#MISE description="Create a new OIDC client"

#USAGE flag "-D --user <user>" help="Kanidm username" default="wtaylor"

read -rp 'Client Id: ' client_name
read -rp 'Display Name: ' client_display
read -rp 'Homepage URL: ' homepage
read -rp 'Redirect URL: ' redirect_url
read -rp 'Scope Map group: ' primary_group
read -rp 'Scope Map scopes: ' scopes

printf "Creating application..."
mise run -q kanidm system oauth2 create "$client_name" "$client_display" "$homepage" -D "${usage_user?}"

printf "Adding redirect url..."
mise run -q kanidm system oauth2 add-redirect-url "$client_name" "$redirect_url" -D "${usage_user?}"

printf "Adding scope map..."
mise run -q kanidm -D "${usage_user?}" system oauth2 update-scope-map "$client_name" "$primary_group" $scopes

printf "Changing preferred_username to short-name"
mise run -q kanidm -D "${usage_user?}" system oauth2 prefer-short-username "$client_name"

echo "Finished creating application"
mise run -q kanidm -D "${usage_user?}" system oauth2 get "$client_name" -o json | yq '{"uuid": .attrs.uuid[0], "display_name": .attrs.displayname[0], "client_id": .attrs.name[0]}'
mise run -q kanidm -D "${usage_user?}" system oauth2 show-basic-secret "$client_name" -o json | yq '{"client_secret": .secret}'
