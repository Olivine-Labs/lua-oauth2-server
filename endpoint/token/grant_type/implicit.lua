local Query = require 'lusty-store.query'

return function(client, context)

  local store = context.store.token
  local input = context.input

  if input.access_token then
    local token = store.get(Query().access_token.eq(input.access_token))[1]
    if token and token.app.client_id == context.global.authorization.client_id then
      local q = Query()['user.id'].eq(token.user.id)['app.client_id'].eq(client.client_id)
      local token = store.get(q)[1]
      if not token then
        local token = {
          token_type = "bearer",
          user = {
            id = token.user.id
          },
          app = {
            client_id = client.client_id
          },
          scope = type(input.scope) == "table" and input.scope or {input.scope},
          access_token = context.global.uuid(),
          refresh_token = context.global.uuid(),
          expires_in = os.time() + context.global.token.expires,
        }
      end
      store.put(q, token)
      token.expires_in = token.expires_in - os.time()
      token._id = nil
      context.response.status = 201
      context.output = token
    else
      context.response.status = 403
    end
  end
end
