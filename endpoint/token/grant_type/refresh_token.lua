local Query = require 'lusty-store.query'

return function(client, context)

  local store = context.store.token
  local input = context.input
  if input.refresh_token then
    local q = Query().refresh_token.eq(input.refresh_token).fields({_id=0})
    local token = store.get(q)[1]
    if token and token.app and token.app.client_id == client.client_id then
      token.refresh_token = context.global.uuid()
      token.expires_in = os.time() + context.global.token.expires
      store.put(q, token)
      token.expires_in = token.expires_in - os.time()
      context.response.status = 200
      context.output = token
    else
      context.response.status = 403
    end
  end
end
