class base::params {
  $puppet_dashboard_url = 'http://localhost:3000'
  $syslog_server = 'util.local'
  $roles = $::system_roles ? {
    undef => [],
    default => split($::system_roles, ','),
  }
}
