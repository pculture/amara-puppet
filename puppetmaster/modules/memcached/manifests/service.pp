class memcached::service inherits memcached::params {
  service { 'memcached': ensure => running, }
}
