class postfix::service {
  if ! defined(Service['postfix']) { service { 'postfix': ensure => running, } }
}