return function(context, client, user, scope)
  local uuid = context.global.uuid

  local token = {
    token_type = "bearer",
    user = {
      id = user.id
    },
    app = {
      client_id = client.client_id
    },
    scope = scope,
    access_token = uuid(),
    refresh_token = uuid(),
    expires_in = os.time() + (client.token_expires_in or 3600),
  }
  return token
end
