local Query = require 'lusty-store.query'
local Token = require 'util.token'

return function(client, context)

  local store = context.store.token
  local input = context.input

  if input.username and input.password then
    local user = context.store.user.get(Query().username.eq(input.username).password.eq(context.global.sha.hmac(context.global.hash.salt, input.password)))[1]

    if user then
      local token = store.get(Query()['user.id'].eq(user.id))[1]
      if not token then
        token = Token(context, client.client_id, user.id, type(input.scope)=="table" and input.scope or {input.scope})
        store.post(token)
      end
      token._id = nil
      token.expires_in = token.expires_in - os.time()
      context.output = token
      context.response.status = 201
    else
      context.response.headers['WWW-Authenticate'] = 'Basic'
      context.response.status = 401
    end
  end
end
