function updates --description "Notifications for homebrew updates"
  # fish shell does not properly support multiline output in variables
  # see https://github.com/fish-shell/fish-shell/issues/159
  # so wrote to file
  comm -1 -3 (brew list --pinned | psub) (brew outdated --quiet | psub) > /tmp/updated

  set -l count (trim (cat /tmp/updated | wc -l))
  set packages (cat /tmp/updated)
  if test $count -eq 0
    /usr/local/bin/terminal-notifier -sender com.apple.Terminal -title "Homebrew" -subtitle "up-to-date"
  else
    /usr/local/bin/terminal-notifier -sender com.apple.Terminal -title "Homebrew" -subtitle "$count updates" -message "$packages"
  end
end
