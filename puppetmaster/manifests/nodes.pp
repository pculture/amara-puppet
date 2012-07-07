node basenode {
  # config for vagrant
  if ($::virtual == 'virtualbox') {
    include base
  } else {
    class { 'base':
      syslog_server => "${config::params::syslog_server}",
    }
  }
  include config
}
node default inherits basenode {}

node puppet inherits basenode {
  include puppetdashboard
  # custom subscribe to restart apache (passenger) on puppet.conf changes
  service { "apache2":
    ensure    => running,
    subscribe => File["base::config::puppet_conf"],
  }
}

