class riemann::package inherits riemann::params {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  if ! defined(Package['openjdk-6-jdk']) { package { 'openjdk-6-jdk': ensure => installed, } }

  exec { 'riemann::package::install':
    command   => "wget $riemann::params::riemann_deb_url -O /tmp/riemann.deb ; dpkg -i /tmp/riemann.deb ; rm /tmp/riemann.deb",
    user      => root,
    creates   => '/usr/bin/riemann',
  }
}
