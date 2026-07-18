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

  printf '\033]2;%s\007' "$sock"            # title = pool name (used to find our window)
  # aerospace detects the window before the title is set, so it lands on t1 (the
  # default rule). Once the title appears, move this exact window to t2 by id.
  if [ "$sock" = secondary ]; then
    (
      n=0
      while [ "$n" -lt 40 ]; do
        wid=$(aerospace list-windows --all --format '%{window-id}|%{window-title}' 2>/dev/null \
              | awk -F'|' '$2 == "secondary" { print $1; exit }')
        [ -n "$wid" ] && { aerospace move-node-to-workspace --window-id "$wid" t2; break; }
        n=$((n + 1))
        sleep 0.1
      done
    ) &
  fi
  sessionizer start --socket-name "$sock"   # keep sessionizer's default session name
  # After detach, become a login shell (window stays open). Deliberate exec: the
  # attaching iteration hands off here and must not fall through to the next sock.
  # shellcheck disable=SC2093
  exec /run/current-system/sw/bin/fish --login --interactive
done

exit 0                                       # both pools busy -> this (3rd) window closes
