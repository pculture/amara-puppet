class appserver::frameworks::python {
  require "appserver::config"

  if ! defined(Package['build-essential']) { package { 'build-essential': ensure => installed, } }
  if ! defined(Package['python-dev']) { package { 'python-dev': ensure => installed, } }
  if ! defined(Package['python-imaging']) { package { 'python-imaging': ensure => installed, } }
  if ! defined(Package['python-memcache']) { package { 'python-memcache': ensure => installed, } }
  if ! defined(Package['python-setuptools']) { package { 'python-setuptools': ensure => installed, } }
  if ! defined(Package['libmysqlclient-dev']) { package { 'libmysqlclient-dev': ensure => installed, } }
  if ! defined(Package['libxml2-dev']) { package { 'libxml2-dev': ensure => installed, } }
  if ! defined(Package['libxslt1-dev']) { package { 'libxslt1-dev': ensure => installed, } }
  if ! defined(Package['swig']) { package { 'swig': ensure => installed, } }

  exec { "appserver::frameworks::python::install_pip":
    path    => "/usr/bin:/usr/local/bin",
    command => "easy_install pip",
    creates => "/usr/local/bin/pip",
  }
  exec { "appserver::frameworks::python::install_virtualenv":
    path    => "/usr/bin:/usr/local/bin",
    command => "pip install virtualenv",
    creates => "/usr/local/bin/virtualenv",
    require => Exec["appserver::frameworks::python::install_pip"],
  }
  exec { "appserver::frameworks::python::install_uwsgi":
    path    => "/usr/bin:/usr/local/bin",
    command => "pip install uwsgi",
    creates => "/usr/local/bin/uwsgi",
    require => [ Package["libxml2-dev"], Package["libxslt1-dev"], Exec["appserver::frameworks::python::install_pip"] ],
  }
  file { 'appserver::frameworks::python::ve_dir':
    ensure  => directory,
    path    => "${appserver::python_ve_dir}",
    owner   => "${appserver::app_user}",
    mode    => 2664,
    group   => "${appserver::app_group}",
    require => Group['appserver::config::app_group'],
  }
}
