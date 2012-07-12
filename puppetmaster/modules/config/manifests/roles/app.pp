class config::roles::app {
  include nginx
  class { 'appserver':
    python  => true,
    nodejs  => false,
    require => Class['nginx'],
  }
  include closure

  class { 'config::config':
    require => [
      Class['appserver'],
      Class['nginx'],
      Class['closure'],
    ],
  }
  # custom role configs
  # app role
  if 'app' in $config::config::roles {
    class { 'config::projects::unisubs':
      project_root  => "${appserver::app_dir}",
      app_user      => "${appserver::app_user}",
      app_group     => "${appserver::app_group}",
      ve_root       => "${appserver::python_ve_dir}",
      require       => Class['appserver::config'],
    }
  }
}