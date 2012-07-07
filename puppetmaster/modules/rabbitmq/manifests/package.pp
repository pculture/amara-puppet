class rabbitmq::package {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  if ! defined(Package["rabbitmq-server"]) { package { "rabbitmq-server": ensure => installed, } }

}
