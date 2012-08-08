class riemann::config inherits riemann::params {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  $graphite_host = $riemann::graphite_host
  # manual symlink to /lib/init/upstart-job for http://projects.puppetlabs.com/issues/14297
  file { '/etc/init.d/riemann':
      ensure  => link,
      target  => '/lib/init/upstart-job',
      alias   => "riemann-upstart-job"
  }
  file { "/etc/init/riemann.conf":
      mode => 0644,
      owner => root,
      group => root,
      source => "puppet:///modules/riemann/riemann.conf",
      alias => "riemann-upstart",
  }
  service { "riemann":
      ensure => running,
      provider => upstart,
      hasrestart => true,
      hasstatus => true,
  }
}
