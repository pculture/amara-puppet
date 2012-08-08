class riemann::package inherits riemann::params {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  if ! defined(Package['openjdk-6-jdk']) { package { 'openjdk-6-jdk': ensure => installed, } }

  exec { 'riemann::package::install':
    command   => "wget $riemann::params::riemann_url -O /tmp/riemann.tar.bz2 ; cd /opt ; tar jxf /tmp/riemann.tar.bz2 ; mv riemann-* riemann ; rm -rf /tmp/riemann",
    user      => root,
    creates   => '/opt/riemann/bin/riemann',
  }
  package { 'riemann-dash':
    ensure    => present,
    provider  => 'gem',
  }
}
