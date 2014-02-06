local basexx = require 'basexx'

local methods = {
  basic = function(data)
    local clientInfo = basexx.from_base64(data)
    local parts = {}
    for part in clientInfo:gmatch("%w+") do parts[#parts+1] = part end

    local authentication = nil
    if #parts == 2 then
      authentication = {
        method = 'basic',
        client_id = parts[1],
        client_secret = parts[2],
      }
    end
    return authentication
  end,

  bearer = function(data)
    return {
      method= 'bearer',
      token = data,
    }
  end,
}

return function(authHeader)
  if authHeader then
    local parts = {}
    for part in authHeader:gmatch("%S+") do parts[#parts+1] = part end
    if #parts == 2 then
      local method = methods[parts[1]:lower()]
      return method and method(parts[2])
    end
  end
end
