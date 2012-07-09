class config::roles::app {
  class { 'appserver':
    python  => true,
    nodejs  => false,
  }
  include nginx
  include closure
  file { 'config::roles::app::upstart_unisubs':
    ensure  => present,
    path    => '/etc/init/uwsgi.unisubs.conf',
    content => template('config/apps/upstart.unisubs.uwsgi.conf.erb'),
    mode    => 0644,
    owner   => root,
  }
  # manual symlink to /lib/init/upstart-job for http://projects.puppetlabs.com/issues/14297
  file { 'config::roles::app::upstart_link_unisubs':
    ensure  => link,
    path    => '/etc/init.d/uwsgi.unisubs',
    target  => '/lib/init/upstart-job',
    require => File['config::roles::app::upstart_unisubs'],
  }
  service { 'uwsgi.unisubs':
    ensure    => running,
    provider  => 'upstart',
    require   => File['config::roles::app::upstart_link_unisubs'],
  }
  class { 'config::config':
    require => [
      Class['appserver'],
      Class['nginx'],
      Class['closure'],
    ],
  }
}