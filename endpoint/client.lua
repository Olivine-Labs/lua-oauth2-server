local store = context.store.client
local methods = {
  POST = function(self)
    if context.input.redirect_uri then
      local original_secret = context.global.uuid()
      local client = {
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
