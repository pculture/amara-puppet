class sensu::server ($configure_rabbitmq=true, $configure_redis=true) {
  require sensu
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  $sensu_rabbitmq_vhost = $sensu::sensu_rabbitmq_vhost
  $sensu_rabbitmq_user = $sensu::sensu_rabbitmq_user
  $sensu_rabbitmq_pass = $sensu::sensu_rabbitmq_pass
  if ($configure_redis) {
    if ! defined(Package['redis-server']) { package { 'redis-server': ensure => installed, } }
    if ! defined(Service['redis-server']) { service { 'redis-server': ensure  => running, } }
    file { '/etc/redis/redis.conf':
      alias   => 'sensu::server::redis_conf',
      ensure  => present,
      content => template('sensu/redis.conf.erb'),
      owner   => root,
      group   => 'redis',
      mode    => 0640,
      require => Package['redis-server'],
      notify  => Service['redis-server'],
    }
    if ! defined(Service['redis-server']) { service { 'redis-server': ensure => running, } }
  }
  # configure rabbit
  if ($configure_rabbitmq) {
    if ! defined(Package['rabbitmq-server']) { package { 'rabbitmq-server': ensure => installed, } }
    exec { 'sensu::server::rabbitmq_vhost':
      command     => "rabbitmqctl add_vhost $sensu_rabbitmq_vhost",
      unless      => "rabbitmqctl list_vhosts | grep $sensu_rabbitmq_vhost",
      require     => Package['rabbitmq-server'],
      notify      => [ Service['sensu-api'], Service['sensu-server'], Service['sensu-dashboard'] ],
    }
    exec { 'sensu::server::rabbitmq_user':
      command   => "rabbitmqctl add_user $sensu_rabbitmq_user $sensu_rabbitmq_pass",
      unless    => "rabbitmqctl list_users | grep $sensu_rabbitmq_user",
      user      => root,
      require     => Package['rabbitmq-server'],
      notify      => [ Service['sensu-api'], Service['sensu-server'], Service['sensu-dashboard'] ],
    }
    exec { 'sensu::server::rabbitmq_vhost_permissions':
      command     => "rabbitmqctl set_permissions -p $sensu_rabbitmq_vhost $sensu_rabbitmq_user \".*\" \".*\" \".*\"",
      user        => root,
      unless      => "rabbitmqctl list_permissions -p $sensu_rabbitmq_vhost | grep -w ^$sensu_rabbitmq_user",
      require     => [ Package['rabbitmq-server'], Exec['sensu::server::rabbitmq_user'], Exec['sensu::server::rabbitmq_vhost'] ],
      notify      => [ Service['sensu-api'], Service['sensu-server'], Service['sensu-dashboard'] ],
    }
  }
  # service
  service { ['sensu-server', 'sensu-api', 'sensu-dashboard']:
    enable    => true,
    ensure    => running,
    provider  => upstart,
    require   => Package['sensu'],
    subscribe => File['/etc/sensu/config.json'],
  }
}
