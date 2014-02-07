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

exec { "oauth2_trusted_client":
  require => [
    Package["mongodb"],
    Package["openssl"],
  ],
  command => "/usr/bin/mongo --eval \"db.client.insert({'client_id':'trusted', 'client_secret':'c907e5e522151738bdbc0f0d0d21beec6d4c123b414cc309aa18602702ab40d0d8b30baf2e40c877f8bbeb061a90137981db0de5a8a20b6fb8bda762f9ad1811', 'trusted':true, 'redirect_uri':'http://localhost/trusted_redirect'})\" localhost/oauth2",
}

exec { "oauth2_untrusted_client":
  require => [
    Package["mongodb"],
    Package["openssl"],
  ],
  command => "/usr/bin/mongo --eval \"db.client.insert({'client_id':'untrusted', 'client_secret':'c907e5e522151738bdbc0f0d0d21beec6d4c123b414cc309aa18602702ab40d0d8b30baf2e40c877f8bbeb061a90137981db0de5a8a20b6fb8bda762f9ad1811', 'redirect_uri':'http://localhost/untrusted_redirect'})\" localhost/oauth2",
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
