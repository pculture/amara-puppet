class base::service {
  if ! defined(Service['ssh']) {
    service { 'ssh':
      ensure  => running,
    }
  }
  if ! defined(Service['rsyslog']) {
    service { 'rsyslog':
      ensure  => running,
    }
  }
  if ! defined(Service['collectd']) {
    service { 'collectd':
      ensure  => running,
    }
  }
}
