class base::config inherits base::params {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  # hack: local /etc/hosts for vagrant
  if ($::is_vagrant == 'true') {
    $dev_group = 'deploy'
    if ! defined(Group["$dev_group"]) {
      group { "$dev_group":
        ensure  => present,
      }
    }
    if ! defined(User['vagrant']) {
      user { 'vagrant':
        groups  => ["$dev_group"],
      }
    }
    file { "base::config::hosts":
      path    => "/etc/hosts",
      owner   => root,
      group   => root,
      mode    => 0644,
      content => template('base/hosts.erb'),
    }
  }
  file { "base::config::puppet_conf":
    path    => "/etc/puppet/puppet.conf",
    owner   => root,
    group   => root,
    mode    => 0644,
    content => template('base/puppet.conf.erb'),
  }
  # syslog
  file { "base::config::default_syslog_conf":
    ensure  => present,
    path    => "/etc/rsyslog.d/50-default.conf",
    content => template("base/rsyslog-50-default.conf.erb"),
    notify  => Service["rsyslog"],
  }
  # apt update
  cron { 'base::config::cron_apt_update':
    command   => 'apt-get update',
    user      => root,
    hour      => '*',
    minute    => '05',
  }
}
