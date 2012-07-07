class nginx::package {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  if ! defined(Package['nginx-full']) { package { 'nginx-full': ensure => installed, } }
}
