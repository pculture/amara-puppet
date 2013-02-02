class config::params {
  $apps_dir = '/opt/apps'
  $ve_root = '/opt/ve'
  $app_group = 'deploy'
  $build_root = '/opt/media_compile'
  $build_apps_root = "$build_root/apps"
  $build_ve_root = "$build_root/ve"
  $envs = $::system_environments ? {
    undef   => [],
    default => split($::system_environments, ','),
  }
  $graphite_host = undef
  $jenkins_port = 8888
  $roles = $::system_roles ? {
    undef => [],
    default => split($::system_roles, ','),
  }
  $syslog_server = 'syslog.amara.org'
}
