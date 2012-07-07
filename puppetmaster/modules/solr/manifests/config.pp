class solr::config inherits solr::params {
  $tomcat_user = 'tomcat6'
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  file { 'solr::config::tomcat_server_conf':
    path    => '/etc/tomcat6/server.xml',
    content => template('solr/server.xml.erb'),
    owner   => "${solr::config::tomcat_user}",
    require => Package["tomcat6"],
  }
  file { 'solr::config::tomcat_users_conf':
    path    => '/etc/tomcat6/tomcat-users.xml',
    content => template('solr/tomcat-users.xml.erb'),
    owner   => "${solr::config::tomcat_user}",
    require => Package["tomcat6"],
  }
  file { 'solr::config::solr_core_dir':
    ensure  => directory,
    path    => '/etc/solr/conf/solr',
    owner   => "${solr::config::tomcat_user}",
    mode    => 0775,
  }
  file { 'solr::config::solr_core_conf':
    ensure  => present,
    content => template('solr/solr.xml.erb'),
    path    => '/usr/share/solr/solr.xml',
    owner   => "${solr::config::tomcat_user}",
    mode    => 0644,
    require => File['solr::config::solr_core_dir'],
    notify  => Service['tomcat6'],
  }
}
