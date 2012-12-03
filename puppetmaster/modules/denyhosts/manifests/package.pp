class denyhosts::package {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  if ! defined(Package["denyhosts"]) { package { "denyhosts": ensure => installed, } }

}
