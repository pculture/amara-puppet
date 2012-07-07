class redis::service {
  service { 'redis':
    ensure    => running,
    provider  => 'upstart',
  }
}