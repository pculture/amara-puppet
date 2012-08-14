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
    mode    => 0644,
    owner   => root,
    group   => root,
    source  => "puppet:///modules/riemann/riemann.conf",
    alias   => "riemann-upstart",
    notify  => Service['riemann'],
  }
  service { 'riemann':
    enable      => true,
    ensure      => running,
    provider    => upstart,
    hasrestart  => true,
    hasstatus   => true,
  }
  if ($riemann::enable_dashboard) {
    # manual symlink to /lib/init/upstart-job for http://projects.puppetlabs.com/issues/14297
    file { '/etc/init.d/riemann-dash':
      ensure  => link,
      target  => '/lib/init/upstart-job',
      alias   => "riemann-dash-upstart-job",
    }
    file { "/etc/init/riemann-dash.conf":
      mode    => 0644,
      owner   => root,
      group   => root,
      source  => "puppet:///modules/riemann/riemann-dash.conf",
      alias   => "riemann-dash-upstart",
      notify  => Service['riemann-dash'],
    }
    service { 'riemann-dash':
      enable      => true,
      ensure      => running,
      provider    => upstart,
      hasrestart  => true,
      hasstatus   => true,
    }
  }
}
