# Class: puppetdashboard
#
# This module manages puppetdashboard
#
# Parameters:
#   dashboard_db_name : Database name
#   dashboard_db_username : Database username
#   dashboard_db_password : Database user password
#
# Actions:
#   Installs and configures the Puppet Dashboard
# Requires:
#   n/a
#
# Sample usage:
#
#  include puppetdashboard
#
class puppetdashboard (
    $config_mysql=$puppetdashboard::params::config_mysql,
    $dashboard_db_name=$puppetdashboard::params::dashboard_db_name, 
    $dashboard_db_username=$puppetdashboard::params::dashboard_db_username,
    $dashboard_db_password=$puppetdashboard::params::dashboard_db_password
  ) inherits puppetdashboard::params {
  class { 'puppetdashboard::config': }
  class { 'puppetdashboard::package':
    require => Class['puppetdashboard::config'],
  }
}
