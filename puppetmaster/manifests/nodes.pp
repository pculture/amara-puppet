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
    class { 'sensu':
      sensu_rabbitmq_host   => 'util.local',
      sensu_redis_host      => 'util.local',
      sensu_api_host        => 'util.local',
      sensu_dashboard_host  => 'util.local',
    }
    class { 'config': graphite_host => '10.10.10.110:2003', require => Class['base'], }
  } else {
    class { 'sensu':
      sensu_rabbitmq_host   => 'util.amara.org',
      sensu_redis_host      => 'util.amara.org',
      sensu_api_host        => 'util.amara.org',
      sensu_dashboard_host  => 'util.amara.org',
    }
    class { 'config': graphite_host => '10.118.146.251:2003', require => Class['base'], }
  }
  class { 'amara': require => [ Class['base'], Class['config'] ], }
}
node default inherits basenode {} # default for all non-defined nodes

node puppet inherits basenode {
  class { 'puppetdashboard': }
  # prune cron job for puppet master
  cron { 'nodes::prune_cron':
    ensure  => present,
    command => "cd /usr/share/puppet-dashboard ; rake RAILS_ENV=production reports:prune upto=7 unit=day 2>&1 > /dev/null",
    user    => root,
    hour    => 22,
    minute  => 30,
  }
  # custom subscribe to restart apache (passenger) on puppet.conf changes
  service { "apache2":
    ensure    => running,
    subscribe => File["base::config::puppet_conf"],
  }
}

