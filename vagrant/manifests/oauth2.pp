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

file { "/etc/openresty/nginx/":
  require => [
    Exec["openresty"],
  ],
  force => true,
  ensure => "link",
  target => "/source/openresty/nginx",
}


file { "/etc/openresty/nginx/sites-enabled/oauth2.conf":
  ensure => "link",
  target => "/source/openresty/nginx/sites-available/oauth2.conf",
}

exec { "oauth2":
  require => [
    File["/etc/openresty/nginx"],
    File["/etc/default/openresty"],
    File["/etc/openresty/nginx/sites-enabled/oauth2.conf"],
    Exec["oauth2_make_app"],
  ],
  command => "/usr/sbin/service openresty restart",
}
