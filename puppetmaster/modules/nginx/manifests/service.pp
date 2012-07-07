class nginx::service {
  service { 'nginx':
    ensure  => running,
  }
}