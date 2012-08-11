class appserver::package {
  if ! defined(Package['openjdk-6-jre']) { package { 'openjdk-6-jre': ensure => installed, } }
  if ! defined(Package['mysql-client']) { package { 'mysql-client': ensure  => present,} }
}
