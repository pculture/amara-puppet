class solr::package {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  if ! defined(Package['tomcat6']) { package { 'tomcat6': ensure => installed, } }
  if ! defined(Package['tomcat6-admin']) { package { 'tomcat6-admin': ensure => installed, } }
  if ! defined(Package['solr-tomcat']) { package { 'solr-tomcat': ensure => installed, } }
}
