return function(context, client, user_id, scope)
  local uuid = context.global.uuid
  local jwt = context.global.jwt
  local alg = context.global.jws.algorithm

  local now = os.time()

  local access_claims = {
    exp = now + (client.access_token_expires_in or 3600),
    nbf = now,
    iat = now,
    jti = uuid(),
    sub = user_id,
    iss = client.client_id,
  }

  local refresh_claims = {
    exp = now + (client.refresh_token_expires_in or 2628000),
    nbf = now,
    iat = now,
    jti = uuid(),
    sub = user_id,
    iss = client.client_id,
  }

  local token = {
    token_type = "bearer",
    client_id = client.client_id,
    user_id = user_id,
    scope = scope,
    access_token = jwt.encode(access_claims, alg, client.client_secret),
    refresh_token = jwt.encode(refresh_claims, alg, client.client_secret),
    expires_in = now + (client.token_expires_in or 3600),
  }
  return token
end
