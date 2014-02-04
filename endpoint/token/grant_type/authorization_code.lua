local Query = require 'lusty-store.query'

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
        token = Token(context, auth.client_id, auth.user.id, auth.scope)
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
    if token and token.client_id == context.global.authorization.client_id then
      local auth = {
        authorization_code = context.global.uuid(),
        user = {
          token.user.id
        },
        app = {
          client_id = client.client_id
        },
        scope = type(input.scope) == "table" and input.scope or {input.scope}
      }
      context.response.status = 201
      context.output = {
        authorization_code = token.authorization_code
      }
    else
      context.response.status = 403
    end
  end
end
