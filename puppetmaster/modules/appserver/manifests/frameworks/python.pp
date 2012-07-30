class appserver::frameworks::python {
  require "appserver::config"

  if ! defined(Class['virtualenv']) { class { 'virtualenv': } }
  if ! defined(Package['build-essential']) { package { 'build-essential': ensure => installed, } }
  if ! defined(Package['python-dev']) { package { 'python-dev': ensure => installed, } }
  if ! defined(Package['libxml2-dev']) { package { 'libxml2-dev': ensure => installed, } }
  if ! defined(Package['libxslt1-dev']) { package { 'libxslt1-dev': ensure => installed, } }

  exec { "appserver::frameworks::python::install_uwsgi":
    path    => "/usr/bin:/usr/local/bin",
    command => "pip install uwsgi",
    creates => "/usr/local/bin/uwsgi",
    require => [ Class['virtualenv'], Package["libxml2-dev"], Package["libxslt1-dev"] ],
  }
  file { 'appserver::frameworks::python::ve_dir':
    ensure  => directory,
    path    => "${appserver::python_ve_dir}",
    owner   => "${appserver::app_user}",
    mode    => 2664,
    group   => "${appserver::app_group}",
    require => Group["${appserver::app_group}"],
  }
}
