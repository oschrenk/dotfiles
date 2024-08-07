function Split(input, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for s in string.gmatch(input, "([^" .. sep .. "]+)") do
    table.insert(t, s)
  end
  return t
end
