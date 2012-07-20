# Class: appserver
#
# This module sets up various appservers (currently python and nodejs)
#
# Parameters:
#
# Actions:
#   Installs and configures various appservers
#
# Sample Usage:
#
#   include appserver
#
class appserver (
    $python=true,
    $nodejs=true,
    $apps_dir=$appserver::params::apps_dir,
    $python_ve_dir=$appserver::params::python_ve_dir,
    $app_user=$appserver::params::app_user,
    $app_group=$appserver::params::app_group,
  ) inherits appserver::params {
  class { 'appserver::config': }
  class { 'appserver::package': 
    require => Class['appserver::config'],
  }
  class { 'appserver::service':
    require => Class['appserver::package'],
  }
  
  if ($python) {
    class { 'appserver::frameworks::python': }
  }
  if ($nodejs) {
    class { 'appserver::frameworks::nodejs': }
  }
}
