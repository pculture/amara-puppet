class celery::config inherits celery::params {
  if ! defined(Group["${celery::celery_group}"]) {
    group { "${celery::celery_group}":
      ensure  => present,
    }
  }
  user { 'celery::config::user':
    name      => "${celery::celery_user}",
    ensure    => present,
    comment   => 'Runs celeryd, celerycam, and celeryev daemons',
    shell     => '/bin/bash',
    gid       => 'celery',
    require   => Group["${celery::celery_group}"],
  }
  file { 'celery::config::log_dir':
    ensure  => directory,
    path    => '/var/log/celery',
    owner   => "${celery::celery_user}",
    group   => "${celery::celery_group}",
    mode    => 0775,
    require => [ User['celery::config::user'], Group["${celery::celery_group}"] ],
  }
  file { 'celery::config::run_dir':
    ensure  => directory,
    path    => '/var/run/celery',
    owner   => "${celery::celery_user}",
    group   => "${celery::celery_group}",
    mode    => 0775,
    require => [ User['celery::config::user'], Group["${celery::celery_group}"] ],
  }
  file { 'celery::config::celeryd':
    ensure  => present,
    path    => '/etc/init.d/celeryd',
    source  => 'puppet:///modules/celery/celeryd',
    owner   => root,
    group   => root,
    mode    => 0755,
  }
  file { 'celery::config::celerybeat':
    ensure  => present,
    path    => '/etc/init.d/celerybeat',
    source  => 'puppet:///modules/celery/celerybeat',
    owner   => root,
    group   => root,
    mode    => 0755,
  }
  file { 'celery::config::celeryevcam':
    ensure  => present,
    path    => '/etc/init.d/celeryevcam',
    source  => 'puppet:///modules/celery/celerybeat',
    owner   => root,
    group   => root,
    mode    => 0755,
  }

}
