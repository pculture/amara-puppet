class config::roles::data {
  # base modules to include
  if ! defined(Class['rabbitmq']) { class { 'rabbitmq': } }
  if ! defined(Class['redis']) { class { 'redis': } }
  if ! defined(Class['solr']) { class { 'solr': } }
  if ! defined(Class['config::config']) {
    class { 'config::config':
      require => [
        Class['rabbitmq'],
        Class['redis'],
        Class['solr'],
      ],
    }
  }
  # extra role packages
  if ! defined(Package['libmysqlclient-dev']) { package { 'libmysqlclient-dev': ensure => installed, } }

  # if running in the local test vagrant multi-vm, include mysql for local testing
  if ($::is_vagrant) {
    if ! defined(Class['mysql']) { class { 'mysql': } }
  }
}