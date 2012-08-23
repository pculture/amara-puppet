class graphite::config inherits graphite::params {
  $carbon_user = 'www-data'
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  file { '/etc/apache2/sites-available/default':
    ensure  => present,
    content => template('graphite/vhost-graphite.conf.erb'),
    mode    => 0644,
    require => Package['apache2'],
    notify  => Service['apache2'],
  }
  file { '/etc/apache2/ports.conf':
    ensure  => present,
    content => template('graphite/ports.conf.erb'),
    mode    => 0644,
    require => Package['apache2'],
    notify  => Service['apache2'],
  }
  file { '/opt/graphite/conf/graphite.wsgi':
    ensure  => present,
    content => template('graphite/graphite.wsgi.erb'),
    notify  => Service['apache2'],
  }
  exec { 'graphite::config::configure_db':
    cwd     => '/opt/graphite/webapp/graphite',
    command => 'python manage.py syncdb --noinput',
    unless  => 'python manage.py inspectdb | grep AuthUser',
  }
  file { '/opt/graphite/storage':
    ensure        => directory,
    owner         => 'www-data',
    group         => 'www-data',
    mode          => 0775,
    notify        => Service['apache2'],
  }
  file { '/opt/graphite/storage/graphite.db':
    owner         => 'www-data',
    group         => 'www-data',
    notify        => Service['apache2'],
  }
  file { '/opt/graphite/storage/log':
    ensure        => directory,
    owner         => 'www-data',
    group         => 'www-data',
    mode          => 0775,
    notify        => Service['apache2'],
  }
  file { '/opt/graphite/storage/rrd':
    ensure        => directory,
    owner         => 'www-data',
    group         => 'www-data',
    mode          => 0775,
    notify        => Service['apache2'],
  }
  file { '/opt/graphite/storage/whisper':
    ensure        => directory,
    owner         => 'www-data',
    group         => 'www-data',
    mode          => 0775,
    notify        => Service['apache2'],
  }
  file { '/opt/graphite/storage/log/webapp':
    ensure    => directory,
    owner     => 'www-data',
    group     => 'www-data',
    recurse   => true,
    notify    => Service['apache2'],
  }
  file { '/opt/graphite/conf/carbon.conf':
    ensure  => present,
    content => template('graphite/carbon.conf.erb'),
  }
  file { '/opt/graphite/conf/storage-schemas.conf':
    ensure  => present,
    content => template('graphite/storage-schemas.conf.erb'),
  }
  file { '/opt/graphite/webapp/graphite/local_settings.py':
    ensure  => present,
    content => template('graphite/local_settings.py.erb'),
    notify  => Service['apache2'],
  }
  # manual symlink to /lib/init/upstart-job for http://projects.puppetlabs.com/issues/14297
  file { '/etc/init.d/carbon-cache':
    ensure  => link,
    target  => '/lib/init/upstart-job',
    alias   => 'carbon-cache-upstart-job',
  }
  file { '/etc/init/carbon-cache.conf':
    ensure  => present,
    mode    => 0644,
    owner   => root,
    group   => root,
    content => template('graphite/carbon-cache.conf.erb'),
    notify  => Service['carbon-cache'],
  }
  # bucky config
  file { '/etc/bucky.cfg':
    ensure  => present,
    owner   => root,
    content => template('graphite/bucky.cfg.erb'),
  }
  # manual symlink to /lib/init/upstart-job for http://projects.puppetlabs.com/issues/14297
  file { '/etc/init.d/bucky':
    ensure  => link,
    target  => '/lib/init/upstart-job',
    alias   => 'bucky-upstart-job',
  }
  file { '/etc/init/bucky.conf':
    ensure  => present,
    mode    => 0644,
    owner   => root,
    group   => root,
    content => template('graphite/bucky.conf.erb'),
    notify  => Service['bucky'],
  }

}
