class solr::config inherits solr::params {
  $tomcat_user = 'tomcat6'
  $envs = $::system_environments ? {
    undef     => [],
    default   => split($::system_environments, ','),
  }
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  define solr_config($env=$name) {
    file { "solr::config::solr_conf_dir_${env}_root":
      ensure  => directory,
      path    => "/etc/solr/conf/${env}",
    }
    file { "solr::config::solr_conf_dir_${env}":
      ensure  => directory,
      path    => "/etc/solr/conf/${env}/conf",
    }
    exec { "solr::config::init_solr_conf_dir_${env}":
      cwd       => '/etc/solr/conf',
      # TODO: mutli-line string ; can't get to work with examples
      command   => "cp -rf admin-extra.html elevate.xml mapping-ISOLatin1Accent.txt protwords.txt schema.xml scripts.conf solrconfig.xml spellings.txt stopwords.txt synonyms.txt xslt /etc/solr/conf/${env}/conf/",
      unless    => "test -e /etc/solr/conf/${env}/conf/schema.xml",
      require   => [ Class['solr'], File["solr::config::solr_conf_dir_${env}"] ],
      notify    => [ Exec["solr::config::solr_conf_dir_permissions_${env}"], Service['tomcat6'] ],
    }
  }
  if ($solr::configure) {
    file { 'solr::config::tomcat_server_conf':
      path    => '/etc/tomcat6/server.xml',
      content => template('solr/server.xml.erb'),
      owner   => "${solr::config::tomcat_user}",
      require => Package["tomcat6"],
    }
    file { 'solr::config::solr_core_conf':
      ensure  => present,
      content => template('solr/solr.xml.erb'),
      path    => '/usr/share/solr/solr.xml',
      owner   => "${solr::config::tomcat_user}",
      mode    => 0644,
      require => Package['solr-tomcat'],
      notify  => Service['tomcat6'],
    }
    # array syntax isn't working (solr_config { $envs: }) ; i'm probably just an idiot
    solr_config { $envs: }
    #if 'local' in $amara::params::envs {
    #  solr_config { 'local': }
    #}
    #if 'dev' in $amara::params::envs {
    #  solr_config { 'dev': }
    #}
    #if 'staging' in $amara::params::envs {
    #  solr_config { 'staging': }
    #}
    #if 'nf' in $amara::params::envs {
    #  solr_config { 'nf': }
    #}
    #if 'production' in $amara::params::envs {
    #  solr_config { 'production': }
    #}
  }
}
