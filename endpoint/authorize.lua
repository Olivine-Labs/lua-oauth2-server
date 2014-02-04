local loginUrl = os.getenv('APP_OAUTH2_LOGIN_URL') or "http://localhost/login"
local Query = require 'lusty-store.query'
local methods = {
  GET = function(self)

    local store = context.store.token
    local query = context.request.query

    if query.client_id and query.response_type then
      local client  = context.store.client.get(Query().id.is(query.client_id))[1]
      if client then
        context.response.status = 302
        context.response.headers.location = loginUrl.."?"..context.request.queryString
        if not context.request.query.redirect_uri then
          context.response.headers.location = context.response.headers.location..'&redirect_uri='..client.redirect_uri
        end
      else
        context.response.status = 404
      end
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
