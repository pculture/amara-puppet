class graphite::service {
  if ! defined(Service['apache2']) { service { 'apache2': ensure  => running, } }
  if ! defined(Service['carbon-cache']) {
    service { 'carbon-cache':
        ensure      => running,
        provider    => upstart,
        hasrestart  => true,
        hasstatus   => true,
    }
  }
}
