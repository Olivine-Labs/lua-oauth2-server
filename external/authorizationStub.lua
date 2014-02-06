local users = config.users
local userById = {}
local userByName = {}

for _, user in pairs(users) do
  userById[user.id] = user
  userByName[user.name] = user
end

local userMethods = {
  login = function(context)
    local user = userByName[context.user.id]
    if user and user.password == context.password then
      return user.id
    end
    return false
  end
}

local clientMethods = {
  canAdd = function(context)
    local user = userById[context.user.id]
    if user and user.admin then
      return true
    end
    return false
  end,
  canEdit = function(context)
    local user = userById[context.user.id]
    if user and user.admin then
       return true
    end
    return false
  end
}

return {
  handler = function(context)
    if context.user.method then
      local method = userMethods[context.user.method]
      return method and method(context)
    elseif context.client.method then
      local method = clientMethods[context.client.method]
      return method and method(context)
    end
  end,
}
