class appserver::frameworks::nodejs {
  require "appserver::config"

  if ! defined(Package["g++"]) { package { "g++": ensure => installed, } }
  if ! defined(Package["curl"]) { package { "curl": ensure => installed, } }
  if ! defined(Package["libssl-dev"]) { package { "libssl-dev": ensure => installed, } }
  if ! defined(Package["apache2-utils"]) { package { "apache2-utils": ensure => installed, } }

  Exec { path => "/bin:/usr/bin:/usr/local/bin", }

  exec { "appserver::frameworks::nodejs::get_nodejs":
    cwd     => "/tmp",
    command => "wget ${appserver::params::nodejs_url} -O nodejs.tar.gz",
    creates => "/usr/local/bin/node",
    notify  => Exec["appserver::frameworks::nodejs::install_nodejs"],
  }
  exec { "appserver::frameworks::nodejs::install_nodejs":
    cwd         => "/tmp",
    command     => "tar zxf nodejs.tar.gz && cd node-* && ./configure && make && make install",
    refreshonly => true,
    timeout     => 1200,
    notify      => Exec["appserver::frameworks::nodejs::cleanup"],
    require     => [ Package["g++"], Package["curl"], Package["libssl-dev"], Package["apache2-utils"] ],
  }
  exec { "appserver::frameworks::nodejs::cleanup":
    cwd         => "/tmp",
    command     => "rm -rf node*",
    refreshonly => true,
  }
}
