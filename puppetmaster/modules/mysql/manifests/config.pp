class mysql::config inherits mysql::params {
  $os_ver = $::operatingsystemrelease
  $mysql_cmd = "mysql -u root -p${mysql::root_password}"
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  exec { 'mysql::config::set_root_password':
    command     => "mysqladmin -u root password \"${mysql::root_password}\"",
    require     => Package['mysql-server'],
    refreshonly => true,
  }
  exec { 'mysql::config::create_unisubs_db':
    command   => "echo \"create database unisubs character set utf8 collate utf8_unicode_ci;\" | ${mysql::config::mysql_cmd}",
    unless    => "echo \"show databases;\" | ${mysql::config::mysql_cmd} | grep unisubs",
    require   => [ Package['mysql-server'], Exec['mysql::config::set_root_password'] ],
  }
  exec { 'mysql::config::permissions_unisubs_db':
    command   => "echo \"grant all on unisubs.* to root@\'%\' identified by \'${mysql::root_password}\';\" | ${mysql::config::mysql_cmd}",
    unless    => "echo \"show grants for root@'%';\" | ${mysql::config::mysql_cmd} | grep \"GRANT ALL PRIVILEGES ON \\`unisubs\\`.* TO 'root'@'%'\"",
    require   => [ Package['mysql-server'], Exec['mysql::config::set_root_password'] ],
  }
  file { 'mysql::config::mysql_config':
    ensure  => present,
    path    => '/etc/mysql/my.cnf',
    content => template('mysql/my.cnf.erb'),
    require => Package['mysql-server'],
    notify  => Service['mysql'],
  }
}
