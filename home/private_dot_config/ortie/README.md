# README

## First setup

1. Visit https://console.developers.google.com/
2. Create a project
3. Create OAuth 2.0 Client ID for a web app
5. add `http://localhost:9999/` as redirect URI
6. Copy client id
7. Copy client secret

```sh
security add-generic-password \
  -s "$KEYCHAIN_ITEM_NAME" \
  -a "$KEYCHAIN_ITEM_ACCOUNT" \
  -w '{"email":"...","client_id":"...","client_secret":"..."}'
```

## Personal setup

```sh
# for legacy/compatibility reasons named after meli cli
export KEYCHAIN_ITEM_NAME=meli-cli
export KEYCHAIN_ITEM_ACCOUNT=MELI

# Store the id/secret via:
security add-generic-password \
  -s "$KEYCHAIN_ITEM_NAME" \
  -a "$KEYCHAIN_ITEM_ACCOUNT" \
  -w '{"email":"...","client_id":"...","client_secret":"..."}'

# find the secret
security find-generic-password -a $KEYCHAIN_ITEM_ACCOUNT -s $KEYCHAIN_ITEM_NAME -w
```

## Usage

```sh
# login (opens consent form in browser)
ortie auth -a personal get

# get refresh token manually (usually not needed)
ortie token -a personal get
```

## Issues

### Refresh access token error (code InvalidGrant)

```sh
$ ortie token -a personal refresh
Error: Refresh access token error (code InvalidGrant)
```

It just means that the refresh token is invalid. This can happen since tokens of projects in "Testing mode" expire after 7 days.

You need to login in again using

```sh
# login (opens consent form in browser)
ortie auth -a personal get
```
