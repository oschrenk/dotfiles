# README

1. Visit https://console.developers.google.com/
2. Create a project
3. Create OAuth 2.0 Client ID for a web app
5. add `http://localhost:9999/` as redirect URI
6. Copy client id
7. Copy client secret

Store

```sh
# Store the id/secret via:
security add-generic-password -s meli-cli -a MELI \
#  -w '{"email":"...","client_id":"...", "client_secret":"..." }'
```
