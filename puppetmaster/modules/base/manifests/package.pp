class base::package {
  require "base::config"

  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  if ! defined(Package['build-essential']) { package { 'build-essential': ensure => installed, } }
  if ! defined(Package['curl']) { package { 'curl': ensure => installed, } }
  if ! defined(Package['git-core']) { package { 'git-core': ensure => installed, } }
  if ! defined(Package['ntp']) { package { 'ntp': ensure => installed, } }
  if ! defined(Package['python-software-properties']) { package { 'python-software-properties': ensure => installed, } }
  if ! defined(Package['supervisor']) { package { 'supervisor': ensure => installed, } }
  if ! defined(Package['vim']) { package { 'vim': ensure => installed, } }

  if ($::is_vagrant) {
    if ! defined(Package['firefox']) { package { 'firefox': ensure => installed, } }
    if ! defined(Package['screen']) { package { 'screen': ensure => installed, } }
  }

}
