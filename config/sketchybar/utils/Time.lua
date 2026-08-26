local time = {}

-- Convert seconds to mm:ss format
time.format_seconds = function(seconds)
  local mins = math.floor(seconds / 60)
  local secs = seconds % 60
  return string.format("%02d:%02d", mins, secs)
end

return time
