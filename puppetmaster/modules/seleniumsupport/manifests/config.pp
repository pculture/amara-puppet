class seleniumsupport::config inherits seleniumsupport::params {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
}
