node basenode {
  # config for vagrant
  if ($::is_vagrant == 'true') {
    include base
  } else {
    class { 'base':
      syslog_server         => "${config::params::syslog_server}",
      puppet_dashboard_url  => 'http://puppet.amara.org:3000'
    }
  }
  # modules
  class { 'postfix': }
  class { 'config': require => Class['base'], }
  class { 'amara': }
}
node default inherits basenode {} # default for all non-defined nodes

node puppet inherits basenode {
  include puppetdashboard
  # custom subscribe to restart apache (passenger) on puppet.conf changes
  service { "apache2":
    ensure    => running,
    subscribe => File["base::config::puppet_conf"],
  }
}

