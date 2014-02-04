$openresty_version = "ngx_openresty-1.5.8.1"
$openresty_source = "http://openresty.org/download/${openresty_version}.tar.gz"

package { 'libreadline-dev':
  ensure => 'installed',
}
package { 'libncurses5-dev':
  ensure => 'installed',
}
package { 'libpcre3-dev':
  ensure => 'installed',
}
package { 'libssl-dev':
  ensure => 'installed',
}
package { 'perl':
  ensure => 'installed',
}
package { 'make':
  ensure => 'installed',
}
package { 'openssl':
  ensure => 'installed',
}

file { "/var/log/openresty":
  ensure => "directory",
}

file { "/etc/default/openresty":
  ensure => 'present',
  content => "",
}

file { "/var/log/openresty/error.log":
  require => [
    File["/var/log/openresty"],
  ],
  ensure => 'present',
  content => "",
}

exec { "openresty_download_source":
  command => "/usr/bin/wget -O /tmp/openresty.tar.gz ${openresty_source}",
}

exec { "openresty_extract_source":
  require => Exec["openresty_download_source"],
  command => "/bin/tar xzvf /tmp/openresty.tar.gz",
  cwd => "/tmp/",
}

exec { "openresty_configure_source":
  require => [  Exec["openresty_extract_source"],
                Package["libreadline-dev"],
                Package["libncurses5-dev"],
                Package["libpcre3-dev"],
                Package["libssl-dev"],
                Package["perl"],
                Package["make"],
                Package["openssl"],
              ],
  cwd => "/tmp/${openresty_version}/",
  command => "/tmp/${openresty_version}/configure --with-luajit --with-http_ssl_module --prefix=/var/lib/openresty --conf-path=/etc/openresty/nginx/nginx.conf",
}

exec { "openresty_make_source":
  cwd => "/tmp/${openresty_version}/",
  require => Exec["openresty_configure_source"],
  command => "/usr/bin/make",
}

exec { "openresty_make_install_source":
  cwd => "/tmp/${openresty_version}/",
  require => Exec["openresty_make_source"],
  command => "/usr/bin/make install",
}

exec { "openresty":
  command => "/bin/true",
  require => [  Exec["openresty_make_install_source"],
                File["/etc/init.d/openresty"],
                File["/etc/init/openresty.conf"],
                File["/var/log/openresty/error.log"]
              ],
}

file { '/etc/init.d/openresty':
   ensure => 'link',
   target => '/lib/init/upstart-job',
}

file { '/etc/init/openresty.conf':
  content => "description \"Openresty\"\nstart on filesystem and net-device-up IFACE!=lo\nstop on runlevel [!2345]\nenv DAEMON=/var/lib/openresty/nginx/sbin/nginx\nenv PID=/var/lib/openresty/nginx/logs/nginx.pid\nrespawn\npre-start script\n \$DAEMON -s stop 2> /dev/null || true\n  if [ -f /etc/default/openresty ]; then . /etc/default/openresty; fi\n  \$DAEMON -t > /dev/null\n  \$DAEMON\nend script\nscript\n sleepWhileAppIsUp(){\n    while pidof \$1 >/dev/null; do\n    sleep 1\n    done\n}\nsleepWhileAppIsUp \$DAEMON\nend script\npost-stop script\n  if pidof > /dev/null \$DAEMON;\n then\n    \$DAEMON -s stop\n fi\nend script",
}
