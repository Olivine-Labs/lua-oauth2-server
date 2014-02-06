local clientMethods = {
  canEdit = function(state)
    state.context = context
    state.client.method = 'canEdit'
    return context.lusty:publish({'user', 'client', 'canEdit'}, state)[1]
  end,
  canAdd = function(state)
    state.context = context
    state.client.method = 'canAdd'
    return context.lusty:publish({'user', 'client', 'canAdd'}, state)[1]
  end
}

local methods = {
  client = function(state)
    return function(client_id)
      state.client = {id = client_id}
      local __meta = {
        __index = function(self, key)
          local method = clientMethods[key]
          return method and method(state)
        end,
        __newindex = function(self, key, value)
          error('Read Only')
        end
      }
      return setmetatable({}, __meta)
    end

  end,
  login = function(state)
    return function(password)
      state.context = context
      state.user.method = 'login'
      state.password = password
      return context.lusty:publish({'user', 'login'}, state)[1]
     end
  end
}

local user = function(id)
  local state = { user = {id = id}}
  local __meta = {
    __index = function(self, key)
      local method = methods[key]
      return method and method(state)
    end,
    __newindex = function(self, key, value)
      error('Read Only')
    end
  }
  return setmetatable({}, __meta)
end

context.user = user
