class celery::config inherits celery::params {
  if ! defined(Group["${celery::celery_group}"]) {
    group { "${celery::celery_group}":
      ensure  => present,
    }
  }
  user { 'celery::config::user':
    name      => "${celery::celery_user}",
    ensure    => present,
    comment   => 'Runs celery daemons',
    shell     => '/bin/bash',
    gid       => 'celery',
    require   => Group["${celery::celery_group}"],
  }
}
