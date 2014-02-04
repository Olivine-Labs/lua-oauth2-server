local store = context.store.user

local methods = {
  POST = function(self)
    local input = context.input
    if input.username and input.password then
      local user = {
        id = context.global.uuid(),
        password = context.global.sha.hmac(context.global.hash.salt, input.password),
        username = context.input.username,
      }
      store.post(user)
      user.password = nil
      user._id = nil
      context.output = user
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
