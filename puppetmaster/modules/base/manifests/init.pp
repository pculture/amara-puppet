# Class: base
#
# This is the core system module
#
# Parameters:
#   n/a
# Actions:
#   Installs and configures the core system
# Requires:
#   n/a
#
# Sample usage:
#
#  include base
#
class base (
    $puppet_dashboard_url=$base::params::puppet_dashboard_url,
    $syslog_server=$base::params::syslog_server,
  ) inherits base::params {
  class { 'base::config': }
  class { 'base::package':
    require => Class['base::config'],
  }
  class { 'base::service':
    require => [ Class['base::config'], Class['base::package'] ],
  }
}
