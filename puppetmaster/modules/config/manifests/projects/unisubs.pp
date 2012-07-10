class config::projects::unisubs ($repo='https://github.com/pculture/unisubs.git', $revision=undef) {
  require closure
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  $settings_module = "${::system_env}" ? {
    'dev'         => 'dev_settings',
    'staging'     => 'test_settings',
    'production'  => 'settings',
    default       => 'dev_settings',
  }
  $env = $::system_env ? {
    undef   => 'dev',
    default => $::system_env,
  }
  $rev = $revision ? {
    undef   => "${::system_env}",
    default => $revision,
  }
  $project_root = "${appserver::app_dir}/universalsubtitles.$env"
  $project_dir = "${config::projects::unisubs::project_root}/unisubs"
  file { 'config::projects::unisubs::project_root':
    ensure  => directory,
    path    => "${config::projects::unisubs::project_root}",
    mode    => 2775,
    owner   => "${appserver::app_user}",
    group   => "${appserver::app_group}",
  }
  # clone repo if not exists ; only for app role
  if 'app' in $config::config::roles {
    vcsrepo { 'config::projects::unisubs':
      path      => "$project_dir",
      provider  => 'git',
      source    => "$repo",
      revision  => "$rev",
    }
    # create virtualenv
    exec { 'config::projects::unisubs::virtualenv':
      command   => "virtualenv --no-site-packages ${appserver::python_ve_dir}/unisubs",
      user      => "${appserver::app_user}",
      creates   => "${appserver::python_ve_dir}/unisubs",
      notify    => Exec['config::projects::unisubs::bootstrap_ve'],
    }
    exec { 'config::projects::unisubs::bootstrap_ve':
      command     => "${appserver::python_ve_dir}/unisubs/bin/pip install -r requirements.txt",
      cwd         => "$project_dir/deploy",
      user        => "${appserver::app_user}",
      refreshonly => true,
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