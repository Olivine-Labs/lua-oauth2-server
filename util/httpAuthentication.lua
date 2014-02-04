local basexx = require 'basexx'
return function(authHeader)
  local authentication = nil
  if authHeader then
    local parts = {}
    for part in authHeader:gmatch("%S+") do parts[#parts+1] = part end
    if #parts == 2 then
      local clientInfo = basexx.from_base64(parts[2])
      local words = {}
      for word in clientInfo:gmatch("%w+") do words[#words+1] = word end

      if #words == 2 then
        authentication = {
          method = parts[1],
          client_id = words[1],
          client_secret = words[2],
        }
      end
    end
  end
  return authentication
end
