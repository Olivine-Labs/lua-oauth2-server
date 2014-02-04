file { "/etc/luarocks/config.lua":
  
  require => Exec["luarocks"],
  content => "rocks_servers = {\n [[http://rocks.moonscript.org]],\n  [[https://raw.github.com/keplerproject/rocks/master]]\n}\n\nrocks_trees = {\n  home..[[/.luarocks]],\n [[/usr/local]]\n}",
}

exec { "moonrocks":
  require => File["/etc/luarocks/config.lua"],
  command => "/bin/true",
}
