class appserver::config inherits appserver::params {
  if ! defined(Group["${appserver::app_group}"]) {
    group { "${appserver::app_group}":
      ensure  => present,
    }
  }
  file { 'appserver::config::apps_dir':
    ensure  => directory,
    path    => "${appserver::apps_dir}",
    owner   => "${appserver::app_user}",
    mode    => 2775,
    group   => "${appserver::app_group}",
    require => Group["${appserver::app_group}"],
  }
  file { 'appserver::config::extras_dir':
    ensure  => directory,
    path    => '/opt/extras',
    owner   => "${appserver::app_user}",
    mode    => 2775,
    group   => "${appserver::app_group}",
    require => Group["${appserver::app_group}"],
  }
}