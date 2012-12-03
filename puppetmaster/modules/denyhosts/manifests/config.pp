class denyhosts::config inherits denyhosts::params {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
}
