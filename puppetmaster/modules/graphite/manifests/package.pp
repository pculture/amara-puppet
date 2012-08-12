class graphite::package inherits graphite::params {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  if ! defined(Package['apache2']) { package { 'apache2': ensure => installed, } }
  if ! defined(Package['libapache2-mod-wsgi']) { package { 'libapache2-mod-wsgi': ensure => installed, } }
  if ! defined(Package['memcached']) { package { 'memcached': ensure => installed, } }
  if ! defined(Package['python-dev']) { package { 'python-dev': ensure => installed, } }
  if ! defined(Package['python-cairo-dev']) { package { 'python-cairo-dev': ensure => installed, } }
  if ! defined(Package['python-django']) { package { 'python-django': ensure => installed, } }
  if ! defined(Package['python-ldap']) { package { 'python-ldap': ensure => installed, } }
  if ! defined(Package['python-memcache']) { package { 'python-memcache': ensure => installed, } }
  if ! defined(Package['python-pysqlite2']) { package { 'python-pysqlite2': ensure => installed, } }
  if ! defined(Package['sqlite3']) { package { 'sqlite3': ensure => installed, } }
  if ! defined(Package['erlang-os-mon']) { package { 'erlang-os-mon': ensure => installed, } }
  if ! defined(Package['erlang-snmp']) { package { 'erlang-snmp': ensure => installed, } }
  if ! defined(Package['rabbitmq-server']) { package { 'rabbitmq-server': ensure => installed, } }
  if ! defined(Package['python-setuptools']) { package { 'python-setuptools': ensure => installed, } }
  if ! defined(Package['python-pip']) { package { 'python-pip': ensure => installed, } }
  # pip
  if ! defined(Package['django-tagging']) { package { 'django-tagging': ensure => installed, provider => 'pip', } }
  # whisper
  exec { 'graphite::package::install_whisper':
    command   => "pip install --use-mirrors $graphite::params::whisper_url",
    creates   => '/usr/local/bin/whisper-update.py',
    require   => Package['python-pip'],
  }
  # carbon
  exec { 'graphite::package::install_carbon':
    command   => "pip install --use-mirrors $graphite::params::carbon_url",
    creates   => '/opt/graphite/bin/carbon-cache.py',
    require   => Package['python-pip'],
  }
  # graphite-web
  exec { 'graphite::package::install_graphite_web':
    command   => "pip install --use-mirrors $graphite::params::graphite_web_url",
    creates   => '/opt/graphite/webapp/graphite/manage.py',
    require   => Package['python-pip'],
  }
  # bucky (collectd to graphite bridge)
  exec { 'graphite::package::install_bucky':
    command   => "pip install --use-mirrors bucky",
    creates   => '/usr/local/bin/bucky',
    require   => Package['python-pip'],
  }

}
