class config::projects::unisubs (
    $repo='https://github.com/pculture/unisubs.git',
    $revision=undef,
    $project_root=undef,
    $app_user=undef,
    $app_group=undef,
    $ve_root=undef,
    $enable_upstart=true,
  ) {
  require closure
  require config

  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  $env = $::env ? {
    undef   => "dev",
    default => "${::env}",
  }
  $settings_module = "${::system_env}" ? {
    'dev'         => 'dev_settings',
    'staging'     => 'test_settings',
    'production'  => 'settings',
    default       => 'dev_settings',
  }
  $rev = $revision ? {
    undef   => "$env",
    default => $revision,
  }
  $server_name = "${::is_vagrant}" ? {
    "true"  => "unisubs.example.com",
    "false" => "$env.universalsubtitles.org",
  }
  $project_dir = "$project_root/unisubs"
  $ve_dir = "$ve_root/unisubs"
  # nginx config (local dev)
  file { 'config::projects::unisubs::vhost_unisubs':
    path    => '/etc/nginx/conf.d/unisubs.example.com.conf',
    content => template('config/apps/unisubs/vhost_unisubs.conf.erb'),
    #owner   => "${nginx::config::www_user}",
    mode    => 0644,
    require => Package['nginx'],
    notify  => Service['nginx'],
  }
  # unisubs repo
  exec { 'config::projects::unisubs::clone_repo':
    command => "git clone $repo $project_dir",
    user    => "$app_user",
    creates => "$project_dir",
    notify  => Exec['config::projects::unisubs::checkout_rev'],
  }
  exec { 'config::projects::unisubs::checkout_rev':
    cwd         => "$project_dir",
    command     => "git checkout --force $rev",
    require     => Exec['config::projects::unisubs::clone_repo'],
    unless      => "test \"`git symbolic-ref HEAD | awk '{split(\$0,s,\"/\"); print s[3]}'`\" = \"$rev\"",
  }
  # create virtualenv
  exec { 'config::projects::unisubs::virtualenv':
    command   => "virtualenv --no-site-packages $ve_dir",
    user      => "$app_user",
    creates   => "$ve_root/unisubs",
    require   => Exec['appserver::frameworks::python::install_virtualenv'],
    notify    => Exec['config::projects::unisubs::bootstrap_ve'],
  }
  exec { 'config::projects::unisubs::bootstrap_ve':
    command     => "$ve_root/unisubs/bin/pip install -r requirements.txt",
    cwd         => "$project_dir/deploy",
    user        => "$app_user",
    require     => Exec['config::projects::unisubs::checkout_rev'],
    timeout     => 1200,
    refreshonly => true,
  }
  # upstart
  if $enable_upstart {
    file { 'config::projects::unisubs::upstart_unisubs':
      ensure  => present,
      path    => '/etc/init/uwsgi.unisubs.conf',
      content => template('config/apps/unisubs/upstart.unisubs.uwsgi.conf.erb'),
      mode    => 0644,
      owner   => root,
    }
    # manual symlink to /lib/init/upstart-job for http://projects.puppetlabs.com/issues/14297
    file { 'config::projects::unisubs::upstart_link_unisubs':
      ensure  => link,
      path    => '/etc/init.d/uwsgi.unisubs',
      target  => '/lib/init/upstart-job',
      require => File['config::projects::unisubs::upstart_unisubs'],
    }
    service { 'uwsgi.unisubs':
      ensure    => running,
      provider  => 'upstart',
      require   => [ File['config::projects::unisubs::upstart_link_unisubs'], Exec['config::projects::unisubs::bootstrap_ve'] ],
    }
  }
  # unisubs closure library link
  file { 'config::projects::unisubs::unisubs_closure_library_link':
    ensure  => link,
    path    => "$project_dir/media/js/closure-library",
    target  => "${closure::closure_local_dir}",
    require => Class['closure'],
  }
  # celery config
  file { 'config::projects::unisubs::celeryd_conf':
    ensure  => present,
    path    => '/etc/default/celeryd',
    content => template('config/apps/unisubs/celeryd_conf.erb'),
    owner   => root,
    group   => root,
    mode    => 0644,
  }
  file { 'config::projects::unisubs::celerybeat_conf':
    ensure  => present,
    path    => '/etc/default/celerybeat',
    content => template('config/apps/unisubs/celerybeat_conf.erb'),
    owner   => root,
    group   => root,
    mode    => 0644,
  }
}