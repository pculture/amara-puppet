class graphite::service {
  if ! defined(Service['apache2']) { service { 'apache2': ensure  => running, } }
  if ! defined(Service['carbon-cache']) {
    service { 'carbon-cache':
      enable      => true,
      ensure      => running,
      provider    => upstart,
      hasrestart  => true,
      hasstatus   => true,
    }
  }
  if ! defined(Service['bucky']) {
    service { 'bucky':
      enable      => true,
      ensure      => running,
      provider    => upstart,
      hasrestart  => true,
      hasstatus   => true,
    }
  }
}
