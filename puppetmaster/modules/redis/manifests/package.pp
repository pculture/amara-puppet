class redis::package {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  if ! defined(Package['build-essential']) { package { 'build-essential': ensure => installed, } }
  exec { 'redis::package::install_redis':
    cwd     => '/tmp',
    command => "wget \"${redis::params::redis_url}\" -O redis.tar.gz ; tar zxf redis.tar.gz ; cd redis-* ; make ; make install ; cd /tmp ; rm -rf redis*",
    creates => '/usr/local/bin/redis-server',
    require => Package['build-essential'],
  }

}
