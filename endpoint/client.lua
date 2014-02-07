local store = context.store.client
local Query = require 'lusty-store.query'
local input = context.input
local authentication = require 'util.httpAuthentication'(context.request.headers.authorization)
local json = require 'cjson'

local methods = {
  POST = function(self)
    if authentication and authentication.method == "bearer" then
      local res = context.request.sub('/token/'..authentication.token)
      if res.status == 200 then
        local token = json.decode(res.body)
        local client = store.get(Query().client_id.eq(token.client_id))[1]

        if client and client.trusted then
          if context.user(token.user_id).client().canAdd then
            if input.redirect_uri then
              local original_secret = context.global.uuid()
              local client = {
                trusted = input.trusted,
                token_expires_in = input.token_expires_in,
                client_id = context.global.uuid(),
                client_secret = context.global.sha.hmac(context.global.hash.salt, original_secret),
                redirect_uri = context.input.redirect_uri,
              }
              store.post(client)
              client.client_secret = original_secret
              client._id = nil
              context.output = client
              context.response.status = 201
            end
          else
            context.response.status = 401
          end
        else
          context.response.status = 401
        end
      else
        context.response.status = 401
      end
    else
      context.response.status = 401
    end
  end,
}
context.output = nil
local method = methods[context.request.method]
if method then
  context.response.status = 400
  return method(methods)
else
  context.response.status = 405
end
