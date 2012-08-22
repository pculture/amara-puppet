class sensu::package {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  # get apt key
  exec { 'sensu::package::apt_key':
    command => 'wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add -',
    user    => root,
    unless  => 'apt-key list | grep -i sensu',
  }
  file { '/etc/apt/sources.list.d/sensu.list':
    alias   => 'sensu::package::apt_source_list',
    ensure  => present,
    content => "deb http://repos.sensuapp.org/apt sensu main\n",
    owner   => root,
    notify  => Exec['sensu::package::apt_update'],
    require => Exec['sensu::package::apt_key'],
  }
  exec { 'sensu::package::apt_update':
    command     => 'apt-get update',
    user        => root,
    refreshonly => true,
  }
  if ! defined(Package["sensu"]) {
    package { "sensu":
      ensure  => installed,
      require => [ File['sensu::package::apt_source_list'], Exec['sensu::package::apt_update'] ],
    }
  }
  if ! defined(Package['sensu-plugin']) { package { 'sensu-plugin': ensure => installed, provider => 'gem', } }
  if ! defined(Package['carrier-pigeon']) { package { 'carrier-pigeon': ensure => installed, provider => 'gem', } }

}
