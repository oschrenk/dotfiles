local strings = {}

strings.split = function(input, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for s in string.gmatch(input, "([^" .. sep .. "]+)") do
    table.insert(t, s)
  end
  return t
end

strings.Trim = function(text, maxLength)
  local Ellipsis = "…"
  if string.len(text) > maxLength then
    return string.sub(text, 0, maxLength) .. Ellipsis
  else
    return text
  end
end

strings.TrimToNil = function(text)
  if text == nil then
    return nil
  end
  local trimmed = text:match("^%s*(.-)%s*$")
  if trimmed == "" then
    return nil
  else
    return trimmed
  end
end

strings.UrlEncode = function(str)
  if str == nil then
    return ""
  end
  str = tostring(str)
  str = string.gsub(str, "\n", "\r\n")
  str = string.gsub(str, "([^%w%-_%.%~])", function(c)
    return string.format("%%%02X", string.byte(c))
  end)
  return str
end

return strings
