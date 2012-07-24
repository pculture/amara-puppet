class appserver::package {
  if ! defined(Package['mysql-client']) { package { 'mysql-client': ensure  => present,} }
}
