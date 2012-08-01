class appserver::config inherits appserver::params {
  if ! defined(Group["${appserver::app_group}"]) {
    group { "${appserver::app_group}":
      ensure  => present,
    }
  }
  if ! defined(File["${appserver::apps_dir}"]) {
    file { "${appserver::apps_dir}":
      alias   => 'appserver::config::apps_dir',
      ensure  => directory,
      owner   => "${appserver::app_user}",
      mode    => 2775,
      group   => "${appserver::app_group}",
      require => Group["${appserver::app_group}"],
    }
  }
  if ! defined(File['/opt/extras']) {
    file { '/opt/extras':
      alias   => 'appserver::config::extras_dir',
      ensure  => directory,
      owner   => "${appserver::app_user}",
      mode    => 2775,
      group   => "${appserver::app_group}",
      require => Group["${appserver::app_group}"],
    }
  }
}