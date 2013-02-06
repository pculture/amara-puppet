class base::package inherits base::params {
  require "base::config"

  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  if ! defined(Package['build-essential']) { package { 'build-essential': ensure => installed, } }
  if ! defined(Package['collectd']) { package { 'collectd': ensure => installed, } }
  if ! defined(Package['curl']) { package { 'curl': ensure => installed, } }
  if ! defined(Package['gawk']) { package { 'gawk': ensure => installed, } }
  if ! defined(Package['git-core']) { package { 'git-core': ensure => installed, } }
  if ! defined(Package['libfreetype6']) { package { 'libfreetype6': ensure => installed, } }
  if ! defined(Package['libfreetype6-dev']) { package { 'libfreetype6-dev': ensure => installed, } }
  if ! defined(Package['libjpeg62']) { package { 'libjpeg62': ensure => installed, } }
  if ! defined(Package['libjpeg62-dev']) { package { 'libjpeg62-dev': ensure => installed, } }
  if ! defined(Package['libmysqlclient-dev']) { package { 'libmysqlclient-dev': ensure => installed, } }
  if ! defined(Package['libssl-dev']) { package { 'libssl-dev': ensure => installed, } }
  if ! defined(Package['mailutils']) { package { 'mailutils': ensure => installed, } }
  if ! defined(Package['mysql-client']) { package { 'mysql-client': ensure => installed, } }
  if ! defined(Package['ntp']) { package { 'ntp': ensure => installed, } }
  if ! defined(Package['python-software-properties']) { package { 'python-software-properties': ensure => installed, } }
  if ! defined(Package['ruby']) { package { 'ruby': ensure => installed, } }
  if ! defined(Package['ruby-dev']) { package { 'ruby-dev': ensure => installed, } }
  if ! defined(Package['rubygems']) { package { 'rubygems': ensure => installed, } }
  if ! defined(Package['s3cmd']) { package { 's3cmd': ensure => installed, } }
  if ! defined(Package['screen']) { package { 'screen': ensure => installed, } }
  if ! defined(Package['supervisor']) { package { 'supervisor': ensure => installed, } }
  if ! defined(Package['vim']) { package { 'vim': ensure => installed, } }
  if ! defined(Package['xfsprogs']) { package { 'xfsprogs': ensure => installed, } }

  if ! defined(Package['crack']) { package { 'crack': ensure => installed, provider => 'gem', require => Package['rubygems'], } }
  if ! defined(Package['mysql']) { package { 'mysql': ensure => installed, provider => 'gem', require => [ Package['rubygems'], Package['libmysqlclient-dev'] ], } }
  if ! defined(Package['mysql2']) { package { 'mysql2': ensure => installed, provider => 'gem', require => [ Package['rubygems'], Package['libmysqlclient-dev'] ], } }
  if ! defined(Package['unzip']) { package { 'unzip': ensure => installed, } }

  if ('vagrant' in $base::params::roles) and ($::is_vagrant == 'true') {
    if ! defined(Package['grc']) { package { 'grc': ensure => installed, } }
  }

}
