class virtualenv::package {
  if ! defined(Package['python-setuptools']) { package { 'python-setuptools': ensure => installed, } }
  if ! defined(Package['libxml2-dev']) { package { 'libxml2-dev': ensure => installed, } }
  if ! defined(Package['libxslt1-dev']) { package { 'libxslt1-dev': ensure => installed, } }

  exec { "virtualenv::package::install_pip":
    path    => "/usr/bin:/usr/local/bin",
    command => "easy_install pip",
    creates => "/usr/local/bin/pip",
  }
  exec { "virtualenv::package::install_virtualenv":
    path    => "/usr/bin:/usr/local/bin",
    command => "pip install virtualenv",
    creates => "/usr/local/bin/virtualenv",
    require => Exec["virtualenv::package::install_pip"],
  }
}