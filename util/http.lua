local http = require 'socket.http'
local ltn12 = require 'ltn12'
local json = require 'dkjson'

local function request(u, method, headers, body)
  local t = {}
  local source = nil
  if body then
    local reqbody = json.encode(body)
    source = ltn12.source.string(reqbody)
    headers["content-length"] = string.len(reqbody)
  end
  local r, c, h = http.request{
    url = u,
    method = method,
    headers = headers,
    sink = ltn12.sink.table(t),
    source = source,
  }
  local data = table.concat(t)
  return json.decode(data), c, h
end

return {
  request = request
}
