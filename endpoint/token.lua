local basexx = require 'basexx'
local store = context.store.token
local Query = require 'lusty-store.query'
local authentication = require 'util.httpAuthentication'(context.request.headers.authorization)

local grant = {
  secret = {
    password          = require 'endpoint.token.grant_type.password',
    refresh_token     = require 'endpoint.token.grant_type.refresh_token',
  },
  client = {
    implicit          = require 'endpoint.token.grant_type.implicit',
    authorization_code= require 'endpoint.token.grant_type.authorization_code',
  }
}

context.response.headers['Cache-Control'] = "no-store"
context.response.headers['Pragma'] = "no-cache"

local methods = {
  GET = function(self)
    local token = store.get(Query().token.is(token).expires_in.gte(os.time()))[1]
    if token then
      context.response.status=200
      token.expires_in = token.expires_in - os.time()
      token.refresh_token = nil
      context.output = token
    else
      context.response.status = 404
    end
  end,

  --[[
  create token
  ]]
  POST = function(self)
    local input = context.input
    if input and input.grant_type and grant.secret[input.grant_type] or grant.client[input.grant_type] then
      local client_id, client_secret
      if authentication and authentication.client_id and authentication.client_secret then
        client_id = authentication.client_id
        client_secret = authentication.client_secret
      else
        client_id = input.client_id
        client_secret = input.client_secret
      end

      if not client_secret then

        if client_id then

          local client = context.store.client.get(Query().client_id.is(client_id))[1]
          if client then
            --execute client id secured grant
            local func = grant.client[input.grant_type]
            if func then func(client, context) end
          end

        else

          context.response.status = 401
          context.response.headers['WWW-Authenticate'] = 'Basic'
        end

      elseif client_id then

        --lookup client
        local client = context.store.client.get(Query().
          client_id.eq(client_id).
          client_secret.eq(
            context.global.sha.hmac(
              context.global.hash.salt,
              client_secret
            )
          )
        )[1]

        if client then
          --execute both secret and client id secured grants
          local func = grant.client[input.grant_type] or grant.secret[input.grant_type]
          if func then func(client, context) end
        else
          context.response.status = 401
          context.response.headers['WWW-Authenticate'] = 'Basic'
        end
      end
    end
  end,

  --[[
  revoke token
  ]]
  DELETE = function(self)
    local q = Query().access_token.eq(token).fields({_id=0,refresh_token=0})
    local token = store.get(q)[1]
    if token then
      store.delete(q)
      token.expires_in = 0
      context.response.status=200
      context.output = token
    else
      context.response.status = 404
    end
  end,
}

local method = methods[context.request.method]
if method then
  context.response.status = 400
  return method(methods)
else
  context.response.status = 405
end