class puppetdashboard::package {
  require "puppetdashboard::config"

  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }

  if ! defined(Package["autoconf"]) { package { "autoconf": ensure => installed, } }
  if ! defined(Package["build-essential"]) { package { "build-essential": ensure => installed, } }
  if ! defined(Package["irb"]) { package { "irb": ensure => installed, } }
  if ! defined(Package["libmysql-ruby"]) { package { "libmysql-ruby": ensure => installed, } }
  if ! defined(Package["libmysqlclient-dev"]) { package { "libmysqlclient-dev": ensure => installed, } }
  if ! defined(Package["libopenssl-ruby"]) { package { "libopenssl-ruby": ensure => installed, } }
  if ! defined(Package["libreadline-ruby"]) { package { "libreadline-ruby": ensure => installed, } }
  if ! defined(Package["rake"]) { package { "rake": ensure => installed, } }
  if ! defined(Package["rdoc"]) { package { "rdoc": ensure => installed, } }
  if ! defined(Package["ri"]) { package { "ri": ensure => installed, } }
  if ! defined(Package["ruby"]) { package { "ruby": ensure => installed, } }
  if ! defined(Package["ruby-dev"]) { package { "ruby-dev": ensure => installed, } }

  exec { "puppetdashboard::package::wget_rubygems":
    cwd       => "/tmp",
    command   => "wget ${puppetdashboard::params::rubygems_url} -O rubygems.tar.gz",
    #creates   => "/usr/bin/gem1.8",
    unless    => "test `gem -v` = '1.3.7'",
    notify    => Exec["puppetdashboard::package::install_rubygems"],
    require   => [ Package["build-essential"], Package["libmysql-ruby"], Package["libmysqlclient-dev"],
    Package["libopenssl-ruby"], Package["rake"], Package["rdoc"], Package["ri"], Package["ruby"], Package["ruby-dev"] ]
  }
  exec { "puppetdashboard::package::install_rubygems":
    cwd         => "/tmp",
    command     => "tar zxf rubygems.tar.gz ; cd rubygems* ; ruby setup.rb ; cd /tmp ; rm -rf rubygems*",
    refreshonly => true,
    require     => Exec["puppetdashboard::package::wget_rubygems"],
    notify      => Exec["puppetdashboard::package::update_alternatives"],
  }
  exec { "puppetdashboard::package::update_alternatives":
    command     => "update-alternatives --install /usr/bin/gem gem /usr/bin/gem1.8 1",
    refreshonly => true,
    require     => Exec["puppetdashboard::package::install_rubygems"],
  }

  # HACK: we use an custom apt policy file to prevent the dashboard from starting after
  # install ; otherwise it will fail because the db:migrate hasn't been run
  # there is supposed to be an option that checks for NO_MIGRATION_CHECK env var but it doesn't work
  exec { "puppetdashboard::package::apt_policy":
    cwd     => "/tmp",
    command => "echo \"#!/bin/sh\nexit 101\n\" > /usr/sbin/policy-rc.d ; chmod +x /usr/sbin/policy-rc.d",
  }
  package { "puppet-dashboard":
    ensure    => installed,
    require   => [ Exec["puppetdashboard::config::update_apt"], Exec["puppetdashboard::package::apt_policy"] ],
    notify    => Exec["puppetdashboard::package::remove_apt_policy"],
  }
  exec { "puppetdashboard::package::remove_apt_policy":
    command     => "rm -f /usr/sbin/policy-rc.d",
    refreshonly => true,
  }
  service { "puppet-dashboard":
    ensure  => running,
    require => Package["puppet-dashboard"],
  }
  service { "puppet-dashboard-workers":
    ensure  => running,
    require => Package["puppet-dashboard"],
  }
  file { "puppetdashboard::package::dashboard_settings":
    path    => "/usr/share/puppet-dashboard/config/settings.yml",
    content => template("puppetdashboard/settings.yml.erb"),
    owner   => root,
    group   => root,
    mode    => 0644,
    require => Package["puppet-dashboard"],
    notify  => [ Service["puppet-dashboard"], Service["puppet-dashboard-workers"] ],
  }

  # mysql config
  if ($puppetdashboard::config_mysql) {
    if ! defined(Package["mysql-server"]) { package { "mysql-server": ensure => installed, } }
    exec { "puppetdashboard::package::create_db":
      command     => "echo 'CREATE DATABASE ${puppetdashboard::params::dashboard_db_name} CHARACTER SET utf8;' | mysql -u root",
      require     => [ Package["mysql-server"], Package["puppet-dashboard"] ],
      notify      => Exec["puppetdashboard::package::create_db_user"],
      unless      => "echo 'show databases;' | mysql -u root | grep ${puppetdashboard::params::dashboard_db_name}",
    }
    exec {"puppetdashboard::package::create_db_user":
      command     => "echo \"CREATE USER '${puppetdashboard::params::dashboard_db_username}'@'localhost' IDENTIFIED BY '${puppetdashboard::params::dashboard_db_password}';\" | mysql -u root",
      require     => Exec["puppetdashboard::package::create_db"],
      notify      => Exec["puppetdashboard::package::grant_db_privs"],
      refreshonly => true,
    }
    exec {"puppetdashboard::package::grant_db_privs":
      command     => "echo 'GRANT ALL PRIVILEGES ON ${puppetdashboard::params::dashboard_db_name}.* TO \'${puppetdashboard::params::dashboard_db_username}\'@\'localhost\';' | mysql -u root",
      require     => Exec["puppetdashboard::package::create_db"],
      refreshonly => true,
      notify      => Exec["puppetdashboard::package::dashboard_configure"],
    }
    file { "puppetdashboard::package::dashboard_database_config":
      path    => "/etc/puppet-dashboard/database.yml",
      content => template("puppetdashboard/database.yml.erb"),
      owner   => "root",
      group   => "www-data",
      mode    => 0640,
      require => Package["puppet-dashboard"],
      notify  => Exec["puppetdashboard::package::dashboard_configure"],
    }
    exec { "puppetdashboard::package::dashboard_configure":
      cwd         => "/usr/share/puppet-dashboard/",
      command     => "rake RAILS_ENV=production db:migrate",
      require     => [ File["puppetdashboard::package::dashboard_database_config"], Exec["puppetdashboard::package::update_alternatives"] ],
      refreshonly => true,
      notify      => [ Service["puppet-dashboard"], Service["puppet-dashboard-workers"] ],
    }
  } else { # don't trigger db:migrate ; just install the config
    file { "puppetdashboard::package::dashboard_database_config":
      path    => "/etc/puppet-dashboard/database.yml",
      content => template("puppetdashboard/database.yml.erb"),
      owner   => "root",
      group   => "www-data",
      mode    => 0640,
      require => Package["puppet-dashboard"],
      notify      => [ Service["puppet-dashboard"], Service["puppet-dashboard-workers"] ],
    }
  }
}
