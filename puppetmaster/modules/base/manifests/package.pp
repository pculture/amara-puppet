class base::package {
  require "base::config"

  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  if ! defined(Package['build-essential']) { package { 'build-essential': ensure => installed, } }
  if ! defined(Package['collectd']) { package { 'collectd': ensure => installed, } }
  if ! defined(Package['curl']) { package { 'curl': ensure => installed, } }
  if ! defined(Package['gawk']) { package { 'gawk': ensure => installed, } }
  if ! defined(Package['git-core']) { package { 'git-core': ensure => installed, } }
  if ! defined(Package['libssl-dev']) { package { 'libssl-dev': ensure => installed, } }
  if ! defined(Package['mailutils']) { package { 'mailutils': ensure => installed, } }
  if ! defined(Package['ntp']) { package { 'ntp': ensure => installed, } }
  if ! defined(Package['python-software-properties']) { package { 'python-software-properties': ensure => installed, } }
  if ! defined(Package['s3cmd']) { package { 's3cmd': ensure => installed, } }
  if ! defined(Package['screen']) { package { 'screen': ensure => installed, } }
  if ! defined(Package['supervisor']) { package { 'supervisor': ensure => installed, } }
  if ! defined(Package['vim']) { package { 'vim': ensure => installed, } }
  if ($::operatingsystem == 'Ubuntu') and ($::operatingsystemrelease == '10.04') {
    if ! defined(Package['rubygems']) { package { 'rubygems': ensure => installed, } }
    if ! defined(Package['ruby1.8-dev']) { package { 'ruby1.8-dev': ensure => installed, } }
  }

  if ('vagrant' in $::system_environments) and ($::is_vagrant) {
    if ! defined(Package['firefox']) { package { 'firefox': ensure => installed, } }
  }

}
