# Inspired by https://blog.josephscott.org/2011/10/14/timing-details-with-curl/
function perf -a url --description "Measure performance of website response"
  set -l format "   time_namelookup: %{time_namelookup}\n      time_connect: %{time_connect}\n   time_appconnect: %{time_appconnect}\n  time_pretransfer: %{time_pretransfer}\n     time_redirect: %{time_redirect}\ntime_starttransfer: %{time_starttransfer}\n                   ------\n        time_total: %{time_total}\n"

  # time_namelookup: The time, in seconds, it took from the start until the name resolving was completed.
  # time_connect: The time, in seconds, it took from the start until the TCP connect to the remote host (or proxy) was completed.
  # time_appconnect: The time, in seconds, it took from the start until the SSL/SSH/etc connect/handshake to the remote host was completed.
  # time_pretransfer The time, in seconds, it took from the start until the file transfer was just about to begin. This includes all pre-transfer commands and negotiations that are specific to the particular protocol(s) involved.
  # time_redirect The time, in seconds, it took for all redirection steps include name lookup, connect, pretransfer and transfer before the final transaction was started. time_redirect shows the complete execution time for multiple redirections. (Added in 7.12.3)
  # time_starttransfer The time, in seconds, it took from the start until the first byte was just about to be transferred. This includes time_pretransfer and also the time the server needed to calculate the result.
  # time_total The total time, in seconds, that the full operation lasted. The time will be displayed with millisecond resolution.

  curl -o /dev/null -s -w "$format" "$url"
end
