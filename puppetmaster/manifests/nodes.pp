node basenode {
  # config for vagrant
  if ($::is_vagrant == 'true') {
    include base
  } else {
    class { 'base':
      syslog_server         => 'syslog.amara.org',
      puppet_dashboard_url  => 'http://puppet.amara.org:3000'
    }
  }
  # modules
  class { 'postfix': }
  if ($::is_vagrant == 'true') {
    class { 'config': graphite_host => '10.10.10.110:2003', require => Class['base'], }
  } else {
    class { 'config': graphite_host => '10.226.105.213:2003', require => Class['base'], }
  }
  class { 'amara': }
}
node default inherits basenode {} # default for all non-defined nodes

node puppet inherits basenode {
  class { 'puppetdashboard': }
  # custom subscribe to restart apache (passenger) on puppet.conf changes
  service { "apache2":
    ensure    => running,
    subscribe => File["base::config::puppet_conf"],
  }
}

