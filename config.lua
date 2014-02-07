local json    = require 'cjson'
local sha1    = require 'sha1'
local env     = os.getenv
local jwt     = require 'jwt'
local file    = 'lusty-request-file.request.file'
local pattern = 'lusty-request-pattern.request.pattern'

--set up good randomization
require 'util.math'

local uuid    = require 'uuid'
uuid.randomseed(math.random(9223372036854775807))

local users = {
  { id = 1, name = "admin", password = "admin", admin = true},
  { id = 2, name = "test", password = "test"},
}

--grant types, and in what situations they may be used
--secret may only be used when a valid client_id and secret are present
--trusted is when secret requirements are met and the client is a trusted one
--client is when a client_id is present
local grant = {
  secret = {
    refresh_token     = require 'endpoint.token.grant.refresh_token',
  },
  client = {
    implicit          = require 'endpoint.token.grant.implicit',
    authorization_code= require 'endpoint.token.grant.authorization_code',
  },
  trusted = {
    password          = require 'endpoint.token.grant.password',
  }
}

local global = {
  grant = grant,
  json  = json,
  uuid  = uuid,
  jwt   = jwt,
  sha   = sha1,
  jws = {
    algorithm = "HS256",
  },
  hash  = {
    salt = env("APP_OAUTH2_SALT") or "kkejjwe438wd"
  },
  token = {
    expires = tonumber(env("APP_OAUTH2_TOKEN_EXPIRES")) or 3600
  },
}

return {
  global = global,

  subscribers = {
    ['rewrite'] = {
      ['lusty-rewrite-param.rewrite.header']  = { header = "accept", param = "_accept" },
      ['lusty-rewrite-param.rewrite.header']  = { header = "content-type", param = "_content-type" },
      ['lusty-rewrite-param.rewrite.header']  = { header= "range", param = "_range" },
      ['lusty-rewrite-param.rewrite.header']  = { header= "authorization", param = "_authorization" },
      ['lusty-rewrite-param.rewrite.method']  = { param = "_method" },
      ['lusty-rewrite-param.rewrite.body']    = { param = "_body" },
    },

    ['input'] = {
      -- decode json input if it exists in the body data.
      -- you can provide -- options to the handler as a table.
      -- in this case, we are passing in a json encoding/decoding function.
      ['lusty-form.input.form'] = {},
      ['lusty-json.input.json'] = { json = global.json }
    },

    -- / is routed to /index in nginx
    ['request'] = { [pattern] = {
      patterns = {
        { ['token[/]?{token}']      = 'endpoint.token' },
        { ['authorize']             = 'endpoint.authorize' },
        { ['client[/]?{clientId}']  = 'endpoint.client' },
        { ['user[/]?{userId}']      = 'endpoint.user' },
      }
    }},

    ['request:400'] = {[file] = 'error.400'},
    ['request:401'] = {[file] = 'error.401'},
    ['request:403'] = {[file] = 'error.403'},
    ['request:404'] = {[file] = 'error.404'},
    ['request:405'] = {[file] = 'error.405'},
    ['request:409'] = {[file] = 'error.409'},
    ['request:500'] = {[file] = 'error.500'},

    ['error'] = {
      ['lusty-error-status.error.status'] = {
        prefix = {{'input'}},
        status = {
          [400] = {{'request:400'}},
          [401] = {{'request:401'}},
          [403] = {{'request:403'}},
          [404] = {{'request:404'}},
          [405] = {{'request:405'}},
          [409] = {{'request:409'}},
          [500] = {{'request:500'}},
        },
        suffix = {{'output'}}
      }
    },

    -- capture json requests to output handler data as json
    ['output'] = {
      ['lusty-json.output.json'] = { json = global.json, default = true }
    },

    ['user'] = {
      ['external.authorizationStub'] = {
        users = users,
      }
    },

    ['store:token'] = {
      ['lusty-store-mongo.store.mongo'] = {
        collection  = env('APP_OAUTH2_TOKEN_DB_COLLECTION')  or 'token',
        host        = env('APP_OAUTH2_TOKEN_DB_HOST')        or '127.0.0.1',
        port        = env('APP_OAUTH2_TOKEN_DB_PORT')        or 27017,
        database    = env('APP_OAUTH2_TOKEN_DB_NAME')        or 'oauth2',
        timeout     = env('APP_OAUTH2_TOKEN_DB_TIMEOUT')     or 5000
      }
    },

    ['store:authorization'] = {
      ['lusty-store-mongo.store.mongo'] = {
        collection  = env('APP_OAUTH2_AUTHORIZATION_DB_COLLECTION')  or 'authorization',
        host        = env('APP_OAUTH2_AUTHORIZATION_DB_HOST')        or '127.0.0.1',
        port        = env('APP_OAUTH2_AUTHORIZATION_DB_PORT')        or 27017,
        database    = env('APP_OAUTH2_AUTHORIZATION_DB_NAME')        or 'oauth2',
        timeout     = env('APP_OAUTH2_AUTHORIZATION_DB_TIMEOUT')     or 5000
      }
    },

    ['store:client'] = {
      ['lusty-store-mongo.store.mongo'] = {
        collection  = env('APP_OAUTH2_CLIENT_DB_COLLECTION')  or 'client',
        host        = env('APP_OAUTH2_CLIENT_DB_HOST')        or '127.0.0.1',
        port        = env('APP_OAUTH2_CLIENT_DB_PORT')        or 27017,
        database    = env('APP_OAUTH2_CLIENT_DB_NAME')        or 'oauth2',
        timeout     = env('APP_OAUTH2_CLIENT_DB_TIMEOUT')     or 5000
      }
    },

    -- log events should write to the console
    -- log events should also go up to nginx
    ['log'] = {
      'lusty-log-console.log.console'
    }
  },

  -- as requests come in, fire these events in order (corresponding to
  -- subscribers above)
  publishers = {
    {'rewrite'},
    {'input'},
    {'request'},
    {'error'},
    {'output'},
  },

  -- bind context methods to the context object that is passed around, so you
  -- can use things like context.log and context.store from within your handler
  context = {
    ['lusty-log.context.log'] = { level = 'debug' },
    ['lusty-store.context.store'] = {},
    ['context.user'] = {},
  }
}
