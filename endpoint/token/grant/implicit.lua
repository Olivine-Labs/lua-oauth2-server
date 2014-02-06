local Query = require 'lusty-store.query'
local Token = require 'util.token'

return function(client, context)

  local store = context.store.token
  local input = context.input

  if input.access_token then

    local token = store.get(Query().access_token.eq(input.access_token))[1]
    local token_client = context.store.client.get(Query().client_id.eq(token.app.client_id))[1]

    if token and token_client and token_client.trusted then

      local q = Query()['user.id'].eq(token.user.id)['app.client_id'].eq(client.client_id).expires_in.gte(os.time())

      local token2 = store.get(q)[1]
      if not token2 then
        token2 = Token(context, client, token.user, type(input.scope) == "table" and input.scope or {input.scope})
        token2.refresh_token = nil
      end

      store.put(q, token2)
      token2.expires_in = token.expires_in - os.time()
      token2._id = nil
      token2.refresh_token = nil
      context.response.status = 201
      context.output = token2
    else
      context.response.status = 403
    end
  end
end
