class config::roles::util {
  # don't use graylog2 to update local syslog config ; base module handles that
  if ! defined(Class['graylog2']) {
    class { 'graylog2':
      update_local_syslog => false,
    }
  }
  if ! defined(Class['nginx']) { class { 'nginx': } }
  if ! defined(Class['graphite']) { class { 'graphite': } }
  if ! defined(Class['sensu::server']) { class { 'sensu::server': } }
  if ! defined(Class['riemann']) {
    class { 'riemann':
      enable_dashboard => false,
      require  => Class['graphite'],
    }
  }
}
