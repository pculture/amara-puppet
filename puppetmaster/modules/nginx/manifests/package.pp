class nginx::package {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  exec { 'nginx::package::nginx_ppa':
    command => 'add-apt-repository ppa:nginx/stable',
    creates => "/etc/apt/sources.list.d/nginx-stable-${::lsbdistcodename}.list",
    notify  => Exec['nginx::package::update_apt'],
    require => Package['python-software-properties'],
  }
  exec { 'nginx::package::update_apt':
    command     => 'apt-get update',
    refreshonly => true,
  }
  if ! defined(Package['nginx']) {
    package { 'nginx':
      ensure  => installed,
      require => [ Exec['nginx::package::nginx_ppa'], Exec['nginx::package::update_apt'] ],
    }
  }
}
