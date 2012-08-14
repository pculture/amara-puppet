class sensu::config inherits sensu::params {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  $sensu_rabbitmq_host = $sensu::sensu_rabbitmq_host
  $sensu_rabbitmq_port = $sensu::sensu_rabbitmq_port
  $sensu_rabbitmq_vhost = $sensu::sensu_rabbitmq_vhost
  $sensu_rabbitmq_user = $sensu::sensu_rabbitmq_user
  $sensu_rabbitmq_pass = $sensu::sensu_rabbitmq_pass
  $sensu_redis_host = $sensu::sensu_redis_host
  $sensu_redis_port = $sensu::sensu_redis_port
  $sensu_dashboard_user = $sensu::sensu_dashboard_user
  $sensu_dashboard_pass = $sensu::sensu_dashboard_pass
  file { '/etc/sensu/config.json':
    ensure  => present,
    content => template('sensu/config.json.erb'),
    owner   => root,
    group   => 'sensu',
    mode    => 0640,
    require => Package['sensu'],
  }
}
