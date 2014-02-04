local Query = require 'lusty-store.query'
local Token = require 'util.token'

return function(client, context)

  local store = context.store.token
  local input = context.input

  if input.access_token then
    local token = store.get(Query().access_token.eq(input.access_token))[1]
    if token and token.app.client_id == context.global.authorization.client_id then
      local q = Query()['user.id'].eq(token.user.id)['app.client_id'].eq(client.client_id).expires_in.gte(os.time())
      local token = store.get(q)[1]
      if not token then
        token = Token(context, client.client_id, token.user.id, type(input.scope) == "table" and input.scope or {input.scope})
        token.refresh_token = nil
      end
      store.put(q, token)
      token.expires_in = token.expires_in - os.time()
      token._id = nil
      token.refresh_token = nil
      context.response.status = 201
      context.output = token
    else
      context.response.status = 403
    end
  end
end
