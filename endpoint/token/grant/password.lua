local Query = require 'lusty-store.query'
local Token = require 'util.token'

return function(client, context)

  local store = context.store.token
  local input = context.input

  if input.username and input.password then
    local user = { id = context.user(input.username).login(input.password)}
    if user and user.id then
      local token = store.get(Query()['user.id'].eq(user.id)['app.client_id'].eq(client.client_id).expires_in.gte(os.time()))[1]
      if not token then
        token = Token(context, client, user, type(input.scope)=="table" and input.scope or {input.scope})
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
