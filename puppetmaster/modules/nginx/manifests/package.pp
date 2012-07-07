class nginx::package {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  if ($::operatingsystemrelease == '10.04') {
    if ! defined(Package['nginx']) { package { 'nginx': ensure => installed, } }
  } else {
    if ! defined(Package['nginx-full']) { package { 'nginx-full': ensure => installed, } }
  }
}
