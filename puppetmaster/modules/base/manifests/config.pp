class base::config inherits base::params {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  $distro_name = $::lsbdistcodename
  $is_vagrant = $::is_vagrant
  $is_ec2 = $::ec2_ami_id ? {
    ""     => false,
    default => true,
  }
  $dev_group = 'deploy'
  if ! defined(Group["$dev_group"]) {
    group { "$dev_group":
      ensure  => present,
    }
  }
  if $::lsbdistid == 'Ubuntu' {
    file { '/etc/apt/sources.list':
      alias   => 'base::config::apt_sources_list',
      ensure  => present,
      content => template('base/sources.list.erb'),
      owner   => root,
      mode    => 0644,
      notify  => Exec['base::config::apt_update'],
    }
  }
  exec { 'base::config::apt_update':
    command     => 'apt-get update',
    user        => root,
    refreshonly => true,
  }

  # timezone
  file { '/etc/timezone':
    ensure  => present,
    content => "Etc/UTC\n",
    notify  => Exec['base::config::update_tzdata'],
  }
  exec { 'base::config::update_tzdata':
    command     => 'dpkg-reconfigure -f noninteractive tzdata',
    refreshonly => true,
  }
  # hack: local /etc/hosts for vagrant
  if ($::is_vagrant == 'true') {
    if ! defined(User['vagrant']) {
      user { 'vagrant':
        groups  => ["$dev_group"],
      }
    }
    if ! defined(User['sandbox']) {
      user { 'sandbox':
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
}
