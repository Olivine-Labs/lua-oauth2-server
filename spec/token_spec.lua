describe("Token Endpoint Specification", function()
  local http = require 'util.http'
  local json = require 'dkjson'

  it("tests token creation grant type password", function()
    local token, code = http.request(
      'http://localhost/token',
      'POST',
      {
        ['Content-Type'] = "application/json",
      },
      {
        grant_type = "password",
        client_id = "trusted",
        client_secret = "oauth2",
        username = "test",
        password = "test"
      }
    )
    assert(code == 201)
    assert(token.access_token)
    assert(token.refresh_token)
    assert(token.user.id == 2)
    assert(token.app.client_id == "trusted")
  end)
end)
