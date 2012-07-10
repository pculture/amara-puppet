class config::projects::unisubs ($repo='https://github.com/pculture/unisubs.git', $revision='dev') {
  require closure

  $env = $::system_env ? {
    undef   => 'dev',
    default => $::system_env,
  }
  $project_root = "${appserver::app_dir}/universalsubtitles.${config::projects::unisubs::env}"
  $project_dir = "${config::projects::unisubs::project_root}/unisubs"
  file { 'config::projects::unisubs::project_root':
    ensure  => directory,
    path    => "${config::projects::unisubs::project_root}",
    mode    => 2775,
    owner   => "${appserver::app_user}",
    group   => "${appserver::app_group}",
  }
  # clone repo if not exists
  vcsrepo { 'config::projects::unisubs':
    path      => "${project_dir}",
    provider  => 'git',
    source    => "$repo",
    revision  => "$revision",
  }
  # unisubs closure library link
  file { 'config::config::unisubs_closure_library_link':
    ensure  => link,
    path    => "${config::projects::unisubs::project_dir}/media/js/closure-library",
    target  => "${closure::closure_local_dir}",
    require => Class['closure'],
  }
}