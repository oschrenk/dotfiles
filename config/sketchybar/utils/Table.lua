local _M = {}

-- Recursively merge default config with user config
function _M.merge(defaults, user)
  local result = {}

  for k, v in pairs(defaults) do
    if type(v) == "table" and type(user[k]) == "table" then
      result[k] = _M.Config(v, user[k])
    else
      result[k] = user[k] ~= nil and user[k] or v
    end
  end

  for k, v in pairs(user or {}) do
    if result[k] == nil then
      result[k] = v
    end
  end

  return result
end

-- Flatten array like table structure
function _M.flatten(t)
  local result = {}

  local function recurse(subtable)
    for _, v in ipairs(subtable) do
      if type(v) == "table" then
        recurse(v)
      elseif type(v) == "string" then
        table.insert(result, v)
      end
    end
  end

  recurse(t)
  return result
end

return _M
