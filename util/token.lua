return function(context, clientId, userId, scope)
  local uuid = context.global.uuid
  local expires = context.global.token.expires

  local token = {
    token_type = "bearer",
    user = {
      id = userId
    },
    app = {
      client_id = clientId
    },
    scope = scope,
    access_token = uuid(),
    refresh_token = uuid(),
    expires_in = os.time() + expires,
  }
  return token
end
