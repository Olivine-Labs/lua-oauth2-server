describe("Client Endpoint Specification", function()
  local http = require 'util.http'
  local json = require 'dkjson'
  local admin_token_trusted
  local admin_token_untrusted
  local user_token
  local clients = {}

  setup(function()
    local res, code = http.request(
      'http://localhost/token',
      'POST',
      {
        ['Content-Type'] = "application/json",
      },
      {
        grant_type = "password",
        client_id = "trusted",
        client_secret = "oauth2",
        username = "admin",
        password = "admin"
      }
    )
    if code ~= 201 then error(code) end
    admin_token_trusted = res.access_token
    local res, code = http.request(
      'http://localhost/token',
      'POST',
      {
        ['Content-Type'] = "application/json",
        ['Authorization'] = "Bearer "..admin_token_trusted,
      },
      {
        grant_type = "implicit",
        client_id = "untrusted",
        username = "admin",
        password = "admin"
      }
    )
    if code ~= 201 then error(code) end
    admin_token_untrusted = res.access_token
    local res = http.request(
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
    user_token = res.access_token
  end)

  teardown(function()
    http.request('http://localhost/token/'..admin_token_untrusted, 'DELETE')
    http.request('http://localhost/token/'..admin_token_trusted, 'DELETE')
    http.request('http://localhost/token/'..user_token, 'DELETE')
  end)

  it("tests client creation by admin user", function()
    local headers = { ["Content-Type"] = "application/json", Authorization = "Bearer "..admin_token_trusted }
    local body = {
      redirect_uri = "http://localhost/"
    }
    local client, code = http.request('http://localhost/client', 'POST', headers, body)
    assert(code == 201)
    assert(client.client_id)
    assert(client.client_secret)
    assert(client.redirect_uri)
  end)

  it("ensures non admin user cannot create clients", function()
    local headers = { ["Content-Type"] = "application/json", Authorization = "Bearer "..user_token }
    local body = {
      redirect_uri = "http://localhost/"
    }
    local client = http.request('http://localhost/client', 'POST', headers, body)
    assert.Equal(401, client.status)
  end)

  it("ensures invalid token cannot create clients", function()
    local headers = { ["Content-Type"] = "application/json", Authorization = "Bearer ".."sdasf" }
    local body = {
      redirect_uri = "http://localhost/"
    }
    local client = http.request('http://localhost/client', 'POST', headers, body)
    assert.Equal(401, client.status)
  end)

  it("ensures token from untrusted client cannot create new clients", function()
    local headers = { ["Content-Type"] = "application/json", Authorization = "Bearer "..admin_token_untrusted }
    local body = {
      redirect_uri = "http://localhost/"
    }
    local client = http.request('http://localhost/client', 'POST', headers, body)
    assert.Equal(401, client.status)
  end)
end)
