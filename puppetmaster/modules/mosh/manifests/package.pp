class mosh::package {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  if ! defined(Package[python-software-properties]) { package { 'python-software-properties': ensure => present } }
  exec { 'mosh::package::mosh_ppa':
    command => 'add-apt-repository ppa:keithw/mosh',
    creates => "/etc/apt/sources.list.d/keithw-mosh-${::lsbdistcodename}.list",
    notify  => Exec['mosh::package::update_apt'],
    require => Package['python-software-properties'],
  }
  exec { 'mosh::package::update_apt':
    command     => 'apt-get update',
    refreshonly => true,
  }
  if ! defined(Package['mosh']) {
    package { 'mosh':
      ensure  => installed,
      require => [ Exec['mosh::package::mosh_ppa'], Exec['mosh::package::update_apt'] ],
    }
  }
}
