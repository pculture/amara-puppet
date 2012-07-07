class rabbitmq::service {
  service { 'rabbitmq-server':
    ensure    => running,
  }
}