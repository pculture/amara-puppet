class appserver::config inherits appserver::params {
  $env = "${amara::env}"
  group { 'appserver::config::app_group':
    name    => "${appserver::app_group}",
    ensure  => present,
  }
  file { 'appserver::config::app_dir':
    ensure  => directory,
    path    => "${appserver::app_dir}",
    owner   => "${appserver::app_user}",
    mode    => 2775,
    group   => "${appserver::app_group}",
    require => Group['appserver::config::app_group'],
  }
  file { 'appserver::config::extras_dir':
    ensure  => directory,
    path    => '/opt/extras',
    owner   => "${appserver::app_user}",
    mode    => 2775,
    group   => "${appserver::app_group}",
    require => Group['appserver::config::app_group'],
  }
}