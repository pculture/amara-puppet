class memcached::package {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  if ! defined(Package["memcached"]) { package { "memcached": ensure => installed, } }
  if ! defined(Package["libmemcached-dev"]) { package { "libmemcached-dev": ensure => installed, } }

}
