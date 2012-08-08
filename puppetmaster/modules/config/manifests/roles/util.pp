class config::roles::util {
  # don't use graylog2 to update local syslog config ; base module handles that
  class { 'graylog2':
    update_local_syslog => false,
  }
  class { 'graphite': }
  class { 'riemann': require  => Class['graphite'], }
  class { 'config::config':
    require => [
      Class['graylog2'],
      Class['riemann'],
    ],
  }
}
