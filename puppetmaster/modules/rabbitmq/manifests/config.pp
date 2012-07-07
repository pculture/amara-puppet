class rabbitmq::config inherits rabbitmq::params {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  exec { 'rabbitmq::config::create_user':
    command   => "rabbitmqctl add_user ${rabbitmq::rabbitmq_user} ${rabbitmq::rabbitmq_password}",
    unless    => "rabbitmqctl list_users | grep ${rabbitmq::rabbitmq_user}",
    user      => root,
    notify    => Exec['rabbitmq::config::permissions'],
  }
  exec { 'rabbitmq::config::permissions':
    command     => "rabbitmqctl set_permissions ${rabbitmq::rabbitmq_user} \".*\" \".*\" \".*\"",
    user        => root,
    refreshonly => true,
  }
}
