#!/usr/bin/env bash

# Wrapper script for kanidm commands
## Historic usage:
### Create user:
# ./kanidm.sh person create wtaylor "William Taylor" --name <authed admin>
### Update user:
# ./kanidm.sh person update wtaylor --legalname "William Taylor" --mail "me@willtaylor.info"
### Resetting credentials:
# ./kanidm.sh person credential create-reset-token wtaylor --name <authed admin>
### Create group:
# ./kanidm.sh group create <group name> --name <authed admin>
### Add person or group to group:
# ./kanidm.sh group add-members <group name> <user/group name> --name <authed admin>
### Create OIDC app
# ./kanidm.sh system oauth2 create <name> <displayname> <landing page url>
### Add redirect url to an OIDC app
# ./kanidm.sh system oauth2 add-redirect-url <name> <redirect url>
# Create/update app scope map
# ./kanidm.sh system oauth2 update-scope-map <name> <kanidm_group_name> [scopes]
# Create a sub scope map for an additional kanidm_group
# ./kanidm.sh system oauth2 update-sup-scope-map <name> <kanidm_other_group_name> [scopes]
# Valid scopes: openid, profile, email, address, phone, groups, groups_name, groups_spn, ssh_publickeys
### Get oauth2 app details
# ./kanidm.sh system oauth2 get <name>
### Get oauth2 client secret
# ./kanidm.sh system oauth2 show-basic-secret <name>
### Create public client
# ./kanidm.sh system oauth2 create-public <name> <displayname> <origin>
### Native apps require localhost redirects
# ./kanidm.sh system oauth2 enable-localhost-redirects <name>
### List clients
# ./kanidm.sh system oauth2 list

if [ ! -f "$HOME/.config/kanidm" ]; then
	echo 'uri = "https://auth.w7x6t.dev"' >"$HOME/.config/kanidm"
fi

if [ ! -f "$HOME/.cache/kanidm_tokens" ]; then
	echo "{}" >"$HOME/.cache/kanidm_tokens"
fi

docker run --rm -i -t \
	--network host \
	--mount "type=bind,src=$HOME/.config/kanidm,target=/root/.config/kanidm" \
	--mount "type=bind,src=$HOME/.cache/kanidm_tokens,target=/root/.cache/kanidm_tokens" \
	kanidm/tools:latest \
	/sbin/kanidm "$@"
