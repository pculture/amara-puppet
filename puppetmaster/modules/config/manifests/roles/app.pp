class config::roles::app {
  # base modules to include
  if ! defined(Class['nginx']) { class { 'nginx': } }
  if ! defined(Class['appserver']) {
    class { 'appserver':
      python  => true,
      nodejs  => false,
      require => Class['nginx'],
    }
  }
  if ! defined(Class['celery']) { class { 'celery': } }
  if ! defined(Class['memcached']) { class { 'memcached': } }

  $envs = $::system_environments ? {
    undef   => ["dev"],
    default => $::system_environments,
  }
  if ! defined(Class['config']) {
    class { 'config::config':
      require => [
        Class['nginx'],
        Class['appserver'],
        Class['closure'],
      ],
    }
  }
  define project_unisubs ($revision=undef, $enable_upstart=true, $env=$name) {
    $apps_root  = "${appserver::apps_dir}"
    $app_user      = "${appserver::app_user}"
    $app_group     = "${appserver::app_group}"
    $ve_root       = "${appserver::python_ve_dir}"
    $requires       = [ Class['appserver::config'], Class['celery'] ]
    config::projects::unisubs { "$name":
      apps_root       => $apps_root,
      app_user        => $app_user,
      app_group       => $app_group,
      ve_root         => $ve_root,
      require         => $requires,
      revision        => $revision,
      env             => $env,
      enable_upstart  => $enable_upstart,
      graphite_host   => $config::graphite_host,
    }
  }
  # setup unisubs project
  if 'local' in $envs {
    project_unisubs { 'local': revision => 'staging', }
  }
  if 'dev' in $envs {
    project_unisubs { 'dev': }
  }
  if 'staging' in $envs {
    project_unisubs { 'staging': }
  }
  if 'nf' in $envs {
    project_unisubs { 'nf': revision => 'x-nf', }
  }
  if 'production' in $envs {
    project_unisubs { 'production': }
  }
  # this is for the development environment
  if 'vagrant' in $envs {
    project_unisubs { 'vagrant': revision => 'dev', }
  }
}
