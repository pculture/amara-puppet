class mysql::package {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  if ! defined(Package['mysql-server']) {
    package { 'mysql-server':
      ensure => installed,
      notify => Exec['mysql::config::set_root_password'],
    }
  }
}
