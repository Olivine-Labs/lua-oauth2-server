package { 'luajit':
  ensure => 'installed',
}

package { 'luarocks':
  ensure => 'installed',
}

file { '/usr/bin/lua':
  require => [
    Package["luarocks"],
    Package["luajit"]
  ],
  ensure => 'link',
  target => '/usr/bin/luajit',
}

package { 'lua-sec':
  ensure => 'installed',
}

exec { "luarocks":
  require => [
    File["/usr/bin/lua"],
    Package['lua-sec'],
  ],
  command => "/bin/true",
}
