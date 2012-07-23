class config::roles::app {
  include nginx
  class { 'appserver':
    python  => true,
    nodejs  => false,
    require => Class['nginx'],
  }
  include closure
  include celery
  $envs = $::system_environments ? {
    undef   => ["dev"],
    default => "${::system_environments}",
  }
  class { 'config::config':
    require => [
      Class['nginx'],
      Class['appserver'],
      Class['closure'],
    ],
  }
  define project_unisubs ($revision=undef) {
    $apps_root  = "${appserver::apps_dir}"
    $app_user      = "${appserver::app_user}"
    $app_group     = "${appserver::app_group}"
    $ve_root       = "${appserver::python_ve_dir}"
    $requires       = [ Class['appserver::config'], Class['celery'] ]
    config::projects::unisubs { "$name":
      apps_root     => $apps_root,
      app_user      => $app_user,
      app_group     => $app_group,
      ve_root       => $ve_root,
      require       => $requires,
      revision      => $revision,
      env           => $name,
    }
  }
  # custom role configs
  # app role
  if 'app' in $config::config::roles {
    # setup unisubs project ; note: the notation project_unisubs { $envs: } isn't working for
    # some reason ; so as a hack, check for the specific envs
    if 'local' in $envs {
      project_unisubs {'local': revision => 'dev',}
    }
    # this is for the development environment
    if 'localdev' in $envs {
      project_unisubs {'localdev': revision => 'dev',}
    }
    if 'dev' in $envs {
      project_unisubs {'dev':}
    }
    if 'staging' in $envs {
      project_unisubs {'staging':}
    }
    if 'nf' in $envs {
      project_unisubs {'nf': revision => 'x-nf',}
    }
    if 'production' in $envs {
      project_unisubs {'production':}
    }
  }
}