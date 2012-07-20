class appserver::config inherits appserver::params {
  group { 'appserver::config::app_group':
    name    => "${appserver::app_group}",
    ensure  => present,
  }
	file { 'appserver::config::apps_dir':
    ensure  => directory,
    path    => "${appserver::apps_dir}",
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