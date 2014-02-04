package { 'libexpat1-dev':
  ensure => 'installed',
}

exec { "oauth2_make_app":
  require => [
    Exec["openresty"],
    Exec["moonrocks"]
  ],
  cwd => "/source",
  command => "/usr/bin/luarocks make",
}

file { "/etc/openresty/nginx/nginx.conf":
  require => [
    Exec["openresty"],
  ],
  ensure => "link",
  target => "/source/openresty/nginx/nginx.conf",
}

exec { "unicorn_model_persistence":
  require => [
    File["/etc/openresty/nginx/nginx.conf"],
    File["/etc/default/openresty"],
    Exec["oauth2_make_app"],
  ],
  command => "/usr/sbin/service openresty restart",
}
