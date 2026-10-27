# Values are stored hex-encoded: `security -w` prints hex instead of text for any
# value with a newline, so this is the only way to hand back the exact bytes.
# Writes go through `security -i` on stdin, so no secret appears in argv.

security=/usr/bin/security
xxd=/usr/bin/xxd

namespace="${MSGVAULT_TOKEN_NAMESPACE:-}"
token_service="msgvault-token${namespace:+:$namespace}"

store() { # service account; value on stdin
  local hex
  hex="$("$xxd" -p | tr -d '\n')"
  [[ -n "$hex" ]] || { echo "msgvault-token: empty value on stdin" >&2; return 1; }
  printf 'add-generic-password -U -s %s -a %s -T %s -w %s\n' "$1" "$2" "$security" "$hex" |
    "$security" -i >/dev/null
  [[ "$("$security" find-generic-password -s "$1" -a "$2" -w 2>/dev/null)" == "$hex" ]] ||
    { echo "msgvault-token: Keychain write for $2 did not stick" >&2; return 1; }
}

fetch() { # service account; exit 3 when absent
  local hex rc=0
  hex="$("$security" find-generic-password -s "$1" -a "$2" -w 2>/dev/null)" || rc=$?
  [[ $rc -eq 44 ]] && return 3
  [[ $rc -eq 0 ]] || { echo "msgvault-token: Keychain read failed ($rc)" >&2; return 1; }
  printf '%s' "$hex" | "$xxd" -r -p
}

account() {
  [[ -n "${MSGVAULT_ACCOUNT:-}" ]] || { echo "msgvault-token: MSGVAULT_ACCOUNT is not set" >&2; exit 1; }
  printf '%s' "$MSGVAULT_ACCOUNT"
}

case "${1:-}" in
  read) fetch "$token_service" "$(account)" ;;
  write) store "$token_service" "$(account)" ;;
  delete)
    rc=0
    "$security" delete-generic-password -s "$token_service" -a "$(account)" >/dev/null 2>&1 || rc=$?
    [[ $rc -eq 0 || $rc -eq 44 ]]
    ;;
  list)
    # dump-keychain without -d prints attributes only, never secret data
    "$security" dump-keychain |
      awk -v svc="$token_service" '
        /^keychain: / { if (s == svc && a != "") print a; s = ""; a = "" }
        /"acct"<blob>="/ { a = $0; sub(/.*"acct"<blob>="/, "", a); sub(/"$/, "", a) }
        /"svce"<blob>="/ { s = $0; sub(/.*"svce"<blob>="/, "", s); sub(/"$/, "", s) }
        END { if (s == svc && a != "") print a }' |
      jq -R . | jq -cs .
    ;;
  client-secret) fetch msgvault-client-secret google ;;
  set-client-secret) store msgvault-client-secret google ;;
  *)
    echo "usage: msgvault-token read|write|delete|list|client-secret|set-client-secret" >&2
    exit 2
    ;;
esac
