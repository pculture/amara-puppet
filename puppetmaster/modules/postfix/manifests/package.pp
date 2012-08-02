class postfix::package {
  if ! defined(Package['postfix']) { package { 'postfix': ensure => installed, } }
  if ! defined(Package['libsasl2-modules']) { package { 'libsasl2-modules': ensure => installed, } }
}
