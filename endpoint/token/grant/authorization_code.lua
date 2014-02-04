local Query = require 'lusty-store.query'
local Token = require 'util.token'

return function(client, context)

  local store = context.store.token
  local input = context.input

  if input.code then

    local q = Query().authorization_code.eq(input.code)
    local auth = context.store.authorization.get(q)[1]
    if auth and auth.app.client_id == client.client_id then
      local q2 = Query()['user.id'].eq(auth.user.id)['app.client_id'].eq(client.client_id).expires_in.gte(os.time())
      local token = store.get(q2)[1]
      if not token then
        token = Token(context, auth.app, auth.user, auth.scope)
      end
      token.scope = auth.scope
      store.put(q2, token)
      token.expires_in = token.expires_in - os.time()
      token._id = nil
      context.response.status = 201
      context.output = token
      auth.authorization_code = nil
      context.store.authorization.put(q, auth)
    end

  elseif input.access_token then

    local token = store.get(Query().access_token.eq(input.access_token))[1]
    local token_client = context.store.client.get(Query().client_id.eq(token.app.client_id))[1]
    if token and token_client and token_client.trusted then

      local q = Query()['user.id'].eq(token.user.id)['app.client_id'].eq(client.client_id)
      local auth = context.store.authorization.get(q)[1]
      if not auth then
        auth = {
          user = {
            id = token.user.id
          },
          app = {
            client_id = client.client_id
          },
          scope = type(input.scope) == "table" and input.scope or {input.scope}
        }
      end
      auth.authorization_code = context.global.uuid()

      context.store.authorization.put(q, auth)

      context.response.status = 201

      context.output = {
        authorization_code = auth.authorization_code
      }
    else
      context.response.status = 403
    end
  end
end
