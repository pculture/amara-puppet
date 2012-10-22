class config::roles::app ($graphite_host=undef, $revisions={}) {
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
    default => split($::system_environments, ','),
  }
  define project_unisubs ($revision=undef, $enable_upstart=true, $enable_celery=false, $env=$name, $apps_root="${appserver::apps_dir}", $ve_root="${appserver::python_ve_dir}") {
    $app_user       = "${appserver::app_user}"
    $app_group      = "${appserver::app_group}"
    $requires       = [ Class['appserver::config'], Class['celery'] ]
    config::projects::unisubs { "$name":
      apps_root       => $apps_root,
      app_user        => $app_user,
      app_group       => $app_group,
      ve_root         => $ve_root,
      require         => $requires,
      revision        => $revision,
      env             => $env,
      enable_celery   => $enable_celery,
      enable_upstart  => $enable_upstart,
      graphite_host   => $config::roles::app::graphite_host,
    }
  }
  # setup unisubs project
  if 'local' in $envs {
    project_unisubs { 'local': revision => $revisions['local'], }
  }
  if 'dev' in $envs {
    project_unisubs { 'dev': revision => $revisions['dev'], }
  }
  if 'staging' in $envs {
    project_unisubs { 'staging': revision => $revisions['staging'], }
  }
  if 'nf' in $envs {
    project_unisubs { 'nf': revision => $revisions['nf'], }
  }
  if 'production' in $envs {
    project_unisubs { 'production': revision => $revisions['production'], }
  }
  # this is for the development environment
  if 'vagrant' in $envs {
    project_unisubs { 'vagrant':
      revision      => $revisions['vagrant'],
      enable_celery => true,
    }
  }
}
