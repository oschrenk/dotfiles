function updates --description "Notifications for homebrew updates"
  brew list --pinned > /tmp/pinned
  brew outdated --quiet > /tmp/outdated
  comm -1 -3 /tmp/pinned /tmp/outdated > /tmp/updated

  set -l count (trim (cat /tmp/updated | wc -l))
  set packages (cat /tmp/updated)
  if test $count -eq 0
    /usr/local/bin/terminal-notifier -sender com.apple.Terminal -title "Homebrew" -subtitle "up-to-date"
  else
    /usr/local/bin/terminal-notifier -sender com.apple.Terminal -title "Homebrew" -subtitle "$count updates" -message "$packages"
  end
end
