package = "lua-oauth2-server"
version = "0.1-0"
source = {
  url = "",
  dir = "."
}
description = {
  summary = "",
  detailed = [[
  ]]
}
dependencies = {
  "lua >= 5.1",
  "busted >= 1.5.0",
  "sha1 >= 0.5-0",
  "lusty >= 0.2-0",
  "lusty-config >= 0.2-0",
  "lusty-json >= 0.3-0",
  "lusty-form >= 0.1-2",
  "lua-cjson >= 2.1.0-1",
  "lusty-log >= 0.1-0",
  "lusty-log-console >= 0.1-0",
  "lusty-nginx >= 0.1-0",
  "lusty-rewrite-param >= 0.4-0",
  "lusty-request-pattern >= 0.1-0",
  "lusty-request-file >= 0.3-0",
  "lusty-error-status >= 0.2-0",
  "lusty-store-mongo == 0.9-1",
  "basexx >= 0.1.0-1",
  "uuid >= 0.2-1",
}
build = {
  type = "builtin",
  modules = {
  },
  install = {
  }
}
