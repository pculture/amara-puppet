class sensu::client {
  require sensu::config
  require sensu::package

  service { 'sensu-client':
    ensure  => running,
    require => Package['sensu'],
    subscribe => File['/etc/sensu/config.json'],
  }
}
