class jenkins::service inherits jenkins::params {
  if ! defined(Service['jenkins']) { service { 'jenkins': ensure => running, } }
}
