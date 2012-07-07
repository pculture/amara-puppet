class memcached::config inherits memcached::params {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
}
