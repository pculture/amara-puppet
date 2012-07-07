class mysql::config inherits mysql::params {
  $mysql_cmd = "mysql -u root -p${mysql::root_password}"
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  exec { 'mysql::config::set_root_password':
    command     => "mysqladmin -u root password \"${mysql::root_password}\"",
    refreshonly => true,
  }
  exec { 'mysql::config::create_unisubs_db':
    command   => "echo \"create database unisubs character set utf8;\" | ${mysql::config::mysql_cmd}",
    unless    => "echo \"show databases;\" | ${mysql::config::mysql_cmd} | grep unisubs",
    require   => Exec['mysql::config::set_root_password'],
  }
}
