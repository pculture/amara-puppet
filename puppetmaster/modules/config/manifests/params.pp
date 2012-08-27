class config::params {
  $envs = $::system_environments ? {
    undef   => [],
    default => split($::system_environments, ','),
  }
  $graphite_host = undef
  $roles = $::system_roles ? {
    undef => [],
    default => split($::system_roles, ','),
  }
  $syslog_server = 'syslog.amara.org'
}
