#!/bin/sh
# tmux-attach-free.sh — give this Ghostty window its own tmux server (socket).
#
#   window 1 -> primary, window 2 -> secondary, window 3+ -> close.
#
# Each socket is a fully isolated session pool: its own switch-client cycle and
# its own sessionizer pool. A session started in one window is invisible to the
# other. SSH uses the default socket, so it never collides or counts here.

# Ghostty launches us with a minimal (launchd) PATH; make our tools resolve.
export PATH="/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:/opt/homebrew/bin:$PATH"

for sock in primary secondary; do
  # A socket whose server has an attached client is taken. When the server does
  # not exist yet, list-clients errors -> empty -> treated as free.
  if tmux -L "$sock" list-clients 2>/dev/null | grep -q .; then
    continue
  fi

  printf '\033]2;%s\007' "$sock"            # set window title early (aerospace, step C)
  sessionizer start --socket-name "$sock" -n "$sock"   # session named after the pool
  # After detach, become a login shell (window stays open). Deliberate exec: the
  # attaching iteration hands off here and must not fall through to the next sock.
  # shellcheck disable=SC2093
  exec /run/current-system/sw/bin/fish --login --interactive
done

exit 0                                       # both pools busy -> this (3rd) window closes
