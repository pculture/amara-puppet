class apache::config inherits apache::params {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
}
