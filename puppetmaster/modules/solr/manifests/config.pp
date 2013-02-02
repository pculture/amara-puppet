class solr::config inherits solr::params {
  $tomcat_user = $solr::params::tomcat_user
  $jvm_mem = $solr::params::jvm_mem
  $envs = $::system_environments ? {
    undef     => [],
    default   => split($::system_environments, ','),
  }
  $extra_cores = $::solr_extra_cores ? {
    undef     => [],
    default   => split($::solr_extra_cores, ','),
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
      notify    => Service['tomcat6'],
    }
  }
  if ($solr::configure) {
    file { '/etc/default/tomcat6':
      alias   => 'solr::config::tomcat_conf',
      content => template('solr/tomcat6.erb'),
      owner   => 'root',
      require => Package['tomcat6'],
      notify  => Service['tomcat6'],
    }
    file { 'solr::config::tomcat_server_conf':
      path    => '/etc/tomcat6/server.xml',
      content => template('solr/server.xml.erb'),
      owner   => "${solr::config::tomcat_user}",
      require => Package['tomcat6'],
    }
  }
  if ($solr::manage_cores) {
    if ! defined(File['/usr/share/solr/solr.xml']) {
      file { '/usr/share/solr/solr.xml':
        ensure  => present,
        content => template('solr/solr.xml.erb'),
        owner   => "${solr::config::tomcat_user}",
        mode    => 0644,
        require => Package['solr-tomcat'],
        notify  => Service['tomcat6'],
      }
    }
    # configure cores
    solr_config { $envs: }
    solr_config { $extra_cores: }
  }
}
