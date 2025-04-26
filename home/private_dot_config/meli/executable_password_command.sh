#!/usr/bin/env sh

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# To safely store the secrets do:
# security add-generic-password -s meli-cli -a MELI \
#  -w '{"email":"...","client_id":"...", "client_secret":"...", "refresh_token": "..."}'

# fetch secrets from secret store
EMAIL=$(security find-generic-password -a MELI -s meli-cli -w | jq -r ".email")
CLIENT_ID=$(security find-generic-password -a MELI -s meli-cli -w | jq -r ".client_id")
CLIENT_SECRET=$(security find-generic-password -a MELI -s meli-cli -w | jq -r ".client_secret")
REFRESH_TOKEN=$(security find-generic-password -a MELI -s meli-cli -w | jq -r ".refresh_token")

# fetch token
TOKEN=$(python3 "$SCRIPT_DIR"/oauth2.py --user="$EMAIL" --quiet --client_id="$CLIENT_ID" --client_secret="$CLIENT_SECRET" --refresh_token="$REFRESH_TOKEN")

# login
python3 "$SCRIPT_DIR"/oauth2.py --user="$EMAIL" --generate_oauth2_string --quiet --access_token="$TOKEN"

