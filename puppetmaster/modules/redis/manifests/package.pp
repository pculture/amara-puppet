class redis::package {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }

  exec { 'redis::package::install_redis':
    cwd     => '/tmp',
    command => "wget \"${redis::params::redis_url}\" -O redis.tar.gz ; tar zxf redis.tar.gz ; cd redis-* ; ./configure ; make ; make install ; cd /tmp ; rm -rf redis*",
    creates => '/usr/local/bin/redis-server',
  }

}
