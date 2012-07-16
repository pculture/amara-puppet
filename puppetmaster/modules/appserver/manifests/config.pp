class appserver::config inherits appserver::params {
  $env = "${config::env}"
  group { 'appserver::config::app_group':
    name    => "${appserver::app_group}",
    ensure  => present,
  }
	file { 'appserver::config::app_dir_root':
    ensure  => directory,
    path    => "${appserver::app_dir_root}",
    owner   => "${appserver::app_user}",
    mode    => 2775,
    group   => "${appserver::app_group}",
    require => Group['appserver::config::app_group'],
  }
  file { 'appserver::config::app_dir':
    ensure  => directory,
    path    => "${appserver::app_dir}",
    owner   => "${appserver::app_user}",
    mode    => 2775,
    group   => "${appserver::app_group}",
    require => [ Group['appserver::config::app_group'], File['appserver::config::app_dir_root'] ],
  }
  file { 'appserver::config::extras_dir':
    ensure  => directory,
    path    => '/opt/extras',
    owner   => "${appserver::app_user}",
    mode    => 2775,
    group   => "${appserver::app_group}",
    require => Group['appserver::config::app_group'],
  }
  cron { 'appserver::config::cron_app_dir_permissions':
    command   => "chown -R ${appserver::app_user}:${appserver::app_group} ${appserver::app_dir} ; chmod -R g+rw ${appserver::app_dir}",
    user      => root,
    hour      => '*',
    minute    => '05',
  }
}