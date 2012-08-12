class base::service {
  service { "rsyslog":
    ensure  => running,
  }
  if ! defined(Service['collectd']) {
    service { 'collectd':
      ensure  => running,
    }
  }
}
