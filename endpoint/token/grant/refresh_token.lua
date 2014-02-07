local Query = require 'lusty-store.query'
local Token = require 'util.token'

return function(client, context)

  local store = context.store.token
  local input = context.input
  if input.refresh_token then
    local q = Query().refresh_token.eq(input.refresh_token).fields({_id=0})
    local token = store.get(q)[1]
    if token then
      local data = context.global.jwt.decode(token.refresh_token)
      local client = context.store.client.get(Query().client_id.eq(data.iss))[1]
      if client and input.client_id == client.client_id then
        token = Token(context, client, data.sub, token.scope)
        store.put(q, token)
        token.client_id = nil
        token.user_id = nil
        token._id = nil
        token.expires_in = token.expires_in - os.time()
        context.response.status = 200
        context.output = token
      else
        context.response.status = 403
      end
    else
      context.response.status = 403
    end
  end
end
