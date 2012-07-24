define config::projects::unisubs (
    $repo='https://github.com/pculture/unisubs.git',
    $revision=undef,
    $apps_root=undef,
    $app_user=undef,
    $app_group=undef,
    $ve_root=undef,
    $enable_upstart=true,
    $env=undef,
  ) {
  require closure
  require config

  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  $roles = $::system_roles ? {
    undef => [],
    default => $::system_roles,
  }
  $settings_module = "$env" ? {
    'local'       => 'dev_settings',
    'dev'         => 'dev_settings',
    'staging'     => 'test_settings',
    'production'  => 'settings',
    default       => 'dev_settings',
  }
  $rev = $revision ? {
    undef   => "$env",
    default => $revision,
  }
  $server_name = "$env" ? {
    'vagrant'    => 'unisubs.example.com',
    'local'       => 'unisubs.local', # this is for the multi-vm environment for infrastructure testing
    'production'  => 'www.universalsubtitles.org',
    default       => "$env.universalsubtitles.org",
  }
  $project_root = "$apps_root/$env"
  $project_dir = "$project_root/unisubs"
  $ve_dir = "$ve_root/unisubs_$env"
  # don't setup project dir for vagrant ; it's symlinked via vagrant
  if ($env != 'vagrant') {
    file { "config::projects::unisubs::project_root_$env":
      ensure  => directory,
      path    => "$project_root",
      owner   => "$app_user",
      group   => "$app_group",
      mode    => 2775,
    }
    cron { "config::project::unisubs::cron_app_dir_permissions_$env":
      command   => "chown -R $app_user:$app_group $project_dir ; chmod -R g+rw $project_dir",
      user      => root,
      hour      => '*',
      minute    => '05',
    }
    # unisubs repo
    exec { "config::projects::unisubs::clone_repo_$env":
      command => "git clone $repo $project_dir",
      user    => "$app_user",
      creates => "$project_dir",
      notify  => Exec["config::projects::unisubs::checkout_rev_$env"],
      require => File["config::projects::unisubs::project_root_$env"],
    }
    exec { "config::projects::unisubs::checkout_rev_$env":
      cwd         => "$project_dir",
      command     => "git checkout --force $rev",
      require     => Exec["config::projects::unisubs::clone_repo_$env"],
      unless      => "test \"`git symbolic-ref HEAD | awk '{split(\$0,s,\"/\"); print s[3]}'`\" = \"$rev\"",
    }
    # unisubs closure library link
    file { "config::projects::unisubs::unisubs_closure_library_link_$env":
      ensure  => link,
      path    => "$project_dir/media/js/closure-library",
      target  => "${closure::closure_local_dir}",
      require => [Exec["config::projects::unisubs::clone_repo_$env"], Class['closure'] ],
    }
    # create virtualenv
    exec { "config::projects::unisubs::virtualenv_$env":
      command   => "virtualenv --no-site-packages $ve_dir",
      user      => "$app_user",
      creates   => "$ve_dir",
      require   => Exec["appserver::frameworks::python::install_virtualenv"],
      notify    => Exec["config::projects::unisubs::bootstrap_ve_$env"],
    }
    exec { "config::projects::unisubs::bootstrap_ve_$env":
      command     => "$ve_dir/bin/pip install -r requirements.txt",
      cwd         => "$project_dir/deploy",
      user        => "$app_user",
      require     => Exec["config::projects::unisubs::checkout_rev_$env"],
      timeout     => 1200,
      refreshonly => true,
    }
    # upstart
    if $enable_upstart {
      file { "config::projects::unisubs::upstart_unisubs_$env":
        ensure  => present,
        path    => "/etc/init/uwsgi.unisubs-$env.conf",
        content => template('config/apps/unisubs/upstart.unisubs.uwsgi.conf.erb'),
        mode    => 0644,
        owner   => root,
      }
      # manual symlink to /lib/init/upstart-job for http://projects.puppetlabs.com/issues/14297
      file { "config::projects::unisubs::upstart_link_unisubs_$env":
        ensure  => link,
        path    => "/etc/init.d/uwsgi.unisubs-$env",
        target  => '/lib/init/upstart-job',
        require => File["config::projects::unisubs::upstart_unisubs_$env"],
      }
      service { "uwsgi.unisubs-$env":
        ensure    => running,
        provider  => 'upstart',
        require   => [ File["config::projects::unisubs::upstart_link_unisubs_$env"], Exec["config::projects::unisubs::bootstrap_ve_$env"] ],
      }
    }
  } else {
    # these are duplicated from above to change requires so the local
    # dev environment that is symlinked from vagrant doesn't get touched
    # unisubs closure library link
    file { "config::projects::unisubs::unisubs_closure_library_link_$env":
      ensure  => link,
      path    => "$project_dir/media/js/closure-library",
      target  => "${closure::closure_local_dir}",
      require => Class['closure'],
    }
    # create virtualenv
    exec { "config::projects::unisubs::virtualenv_$env":
      command   => "virtualenv --no-site-packages $ve_dir",
      user      => "$app_user",
      creates   => "$ve_dir",
      require   => Exec["appserver::frameworks::python::install_virtualenv"],
    }
  }

  # local email dir
  file { "config::projects::unisubs::email_messages_dir_$env":
    ensure  => directory,
    path    => "/tmp/unisubs-messages_$env",
    owner   => "$app_user",
    mode    => 0750,
  }
  # celery config
  file { "config::projects::unisubs::celeryd_conf_$env":
    ensure  => present,
    path    => "/etc/default/celeryd.$env",
    content => template('config/apps/unisubs/celeryd_conf.erb'),
    owner   => root,
    group   => root,
    mode    => 0644,
  }
  file { "config::projects::unisubs::celerybeat_conf_$env":
    ensure  => present,
    path    => "/etc/default/celerybeat.$env",
    content => template('config/apps/unisubs/celerybeat_conf.erb'),
    owner   => root,
    group   => root,
    mode    => 0644,
  }
  # symlinks for celery - needed for celery module (celeryd, celerybeat)
  # NOTE: on multi-env setups, this will only be created for the first env as subsequent
  # ones would just overwrite the symlink
  if ! defined(File['config::projects::unisubs::celeryd_symlink']) {
    file { "config::projects::unisubs::celeryd_symlink":
      ensure    => link,
      path      => '/etc/default/celeryd',
      target    => "/etc/default/celeryd.$env",
      require   => File["config::projects::unisubs::celeryd_conf_$env"],
    }
  }
  if ! defined(File['config::projects::unisubs::celerybeat_symlink']) {
    file { "config::projects::unisubs::celerybeat_symlink":
      ensure    => link,
      path      => '/etc/default/celerybeat',
      target    => "/etc/default/celerybeat.$env",
      require   => File["config::projects::unisubs::celerybeat_conf_$env"],
    }
  }
  # nginx
  file { "config::projects::unisubs::vhost_unisubs_$env":
    path    => "/etc/nginx/conf.d/$server_name.conf",
    content => template('config/apps/unisubs/vhost_unisubs.conf.erb'),
    #owner   => "${nginx::config::www_user}",
    mode    => 0644,
    require => Package['nginx'],
    notify  => Service['nginx'],
  }
  # vagrant setup
  if ($::is_vagrant) and ($env == 'vagrant') {
    # vagrant vagrant setup
    #user { 'vagrant':
    #  ensure  => present,
    #}
    file { 'config::projects::unisubs::vagrant_bashrc':
      ensure  => present,
      path    => '/home/vagrant/.bashrc',
      content => template('config/apps/unisubs/bashrc.erb'),
      owner   => 'vagrant',
      group   => 'vagrant',
      mode    => 0644,
      #require => User['vagrant'],
    }
    # # nginx
    #     file { 'config::projects::unisubs::vhost_unisubs_vagrant':
    #       path    => '/etc/nginx/conf.d/unisubs.example.com.conf',
    #       content => template('config/apps/unisubs/vhost_unisubs.conf.erb'),
    #       #owner   => "${nginx::config::www_user}",
    #       mode    => 0644,
    #       require => Package['nginx'],
    #       notify  => Service['nginx'],
    #     }
  }

}