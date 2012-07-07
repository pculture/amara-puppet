class puppetdashboard::config inherits puppetdashboard::params {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }

  exec { "puppetdashboard::config::config_puppetlabs_repo":
    cwd     => "/tmp",
    command => "wget --quiet \"${puppetdashboard::params::puppetlabs_deb_url}\" -O puppetlabs.deb ; dpkg -i puppetlabs.deb",
    creates => "/etc/apt/sources.list.d/puppetlabs.list",
    notify  => Exec["puppetdashboard::config::update_apt"],
  }
  exec { "puppetdashboard::config::update_apt":
    command     => "apt-get -y update",
    user        => root,
    require     => Exec["puppetdashboard::config::config_puppetlabs_repo"],
    refreshonly => true,
  }
  file { "puppetdashboard::config::dashboard_default":
    path    => "/etc/default/puppet-dashboard",
    content => template("puppetdashboard/dashboard_default.erb"),
    owner   => "root",
    group   => "root",
    mode    => 0644,
  }
  file { "puppetdashboard::config::dashboard-workers_default":
    path    => "/etc/default/puppet-dashboard-workers",
    content => template("puppetdashboard/dashboard-workers_default.erb"),
    owner   => "root",
    group   => "root",
    mode    => 0644,
  }
}
