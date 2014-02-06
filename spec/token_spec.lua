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

  it("ensures token creation with grant type password can not be done from an untrusted client", function()
    local token, code = http.request(
      'http://localhost/token',
      'POST',
      {
        ['Content-Type'] = "application/json",
      },
      {
        grant_type = "password",
        client_id = "untrusted",
        client_secret = "oauth2",
        username = "test",
        password = "test"
      }
    )
    assert(code == 400)
  end)

  it("tests grant type implicit", function()
    local trusted_token, code = http.request(
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
    local token, code = http.request(
      'http://localhost/token',
      'POST',
      {
        ['Content-Type'] = "application/json",
        ['Authorization'] = "Bearer "..trusted_token.access_token,
      },
      {
        grant_type = "implicit",
        client_id = "untrusted",
        username = "test",
        password = "test"
      }
    )
    if code ~= 201 then error(json.encode(token)) end
    assert.equal(code, 201)
    assert(token.access_token)
    assert(token.refresh_token == nil)
    assert(token.expires_in)
    assert(token.user.id == 2)
    assert(token.app.client_id == "untrusted")
  end)
end)
