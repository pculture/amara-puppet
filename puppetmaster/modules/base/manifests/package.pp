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

  if ! defined(Package['crack']) { package { 'crack': ensure => installed, provider => 'gem', require => Package['rubygems'], } }
  if ! defined(Package['mysql']) { package { 'mysql': ensure => installed, provider => 'gem', require => [ Package['rubygems'], Package['libmysqlclient-dev'] ], } }
  if ! defined(Package['mysql2']) { package { 'mysql2': ensure => installed, provider => 'gem', require => [ Package['rubygems'], Package['libmysqlclient-dev'] ], } }

  if ('vagrant' in $base::params::roles) and ($::is_vagrant == 'true') {
    # Google Chrome for selenium
    # get apt key
    exec { 'base::package::google_apt_key':
      command => 'wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -',
      user    => root,
      unless  => 'apt-key list | grep -i google',
    }
    file { '/etc/apt/sources.list.d/google-chrome.list':
      alias   => 'base::package::google_chrome_apt_source_list',
      ensure  => present,
      content => "deb http://dl.google.com/linux/deb/ stable main\n",
      owner   => root,
      notify  => Exec['base::package::apt_update'],
      require => Exec['base::package::google_apt_key'],
    }
    exec { 'base::package::apt_update':
      command     => 'apt-get update',
      user        => root,
      refreshonly => true,
    }
    if ! defined(Package["google-chrome-stable"]) {
      package { "google-chrome-stable":
        ensure  => installed,
        require => [ File['base::package::google_chrome_apt_source_list'], Exec['base::package::apt_update'] ],
      }
    }
    if ! defined(Package['grc']) { package { 'grc': ensure => installed, } }
    if ! defined(Package['firefox']) { package { 'firefox': ensure => installed, } }
    if ! defined(Package['flashplugin-installer']) { package { 'flashplugin-installer': ensure => installed, } }
    if ! defined(Package['xvfb']) { package { 'xvfb': ensure => installed, } }
  }

}
