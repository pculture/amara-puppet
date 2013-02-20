class mosh::config inherits mosh::params {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
}
