class redis::config inherits redis::params {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  user { 'redis::config::redis_user':
    name    => "${redis::redis_user}",
    comment => "Redis",
    home    => "/home/${redis::redis_user}",
    ensure  => present,
  }
  file { 'redis::config::log_dir':
    ensure  => directory,
    path    => "${redis::log_dir}",
    mode    => 0750,
    owner   => "${redis::redis_user}",
  }
  file { 'redis::config::data_dir':
    ensure  => directory,
    path    => "${redis::data_dir}",
    owner   => "${redis::redis_user}",
    mode    => 0750,
    require => User["redis::config::redis_user"],
  }
  file { 'redis::config::redis_conf':
    path    => '/etc/redis.conf',
    content => template('redis/redis.conf.erb'),
    owner   => "${redis::redis_user}",
    mode    => 0644,
    notify  => Service['redis'],
  }
  # manual symlink to /lib/init/upstart-job for http://projects.puppetlabs.com/issues/14297
  file { 'redis::config::redis_upstart_link':
    ensure  => link,
    path    => '/etc/init.d/redis',
    target  => '/lib/init/upstart-job',
    alias   => "redis-upstart-job"
  }
  file { 'redis::config::redis_upstart':
    path    => '/etc/init/redis.conf',
    content => template('redis/redis.conf.upstart.erb'),
    owner   => root,
    mode    => 0644,
    require => File['redis::config::redis_upstart_link'],
    notify  => Service['redis'],
  }
  file { 'redis::config::redis_logrotate':
    path    => '/etc/logrotate.d/redis',
    content => template('redis/redis.logrotate.erb'),
    owner   => root,
    mode    => 0644,
  }
}
