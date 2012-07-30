class config::roles::data {
  # base modules to include
  if ! defined(Class['rabbitmq']) { class { 'rabbitmq': } }
  if ! defined(Class['redis']) { class { 'redis': } }
  if ! defined(Class['solr']) { class { 'solr': } }
  if ! defined(Class['config::config']) {
    class { 'config::config':
      require => [
        Class['rabbitmq'],
        Class['redis'],
        Class['solr'],
      ],
    }
  }
  if ! defined(Class['virtualenv']) { class { 'virtualenv': } }

  # extra role packages
  if ! defined(Package['libmysqlclient-dev']) { package { 'libmysqlclient-dev': ensure => installed, } }

  # if running in the local test vagrant multi-vm, include mysql for local testing
  if ($::is_vagrant) {
    if ! defined(Class['mysql']) { class { 'mysql': } }
  }
  define project_unisubs ($revision=undef, $enable_upstart=false, $env=$name) {
    config::projects::unisubs { "$name":
      apps_root       => $config::apps_dir,
      app_group       => $config::app_group,
      ve_root         => $config::ve_root,
      revision        => $revision,
      env             => $env,
      enable_upstart  => $enable_upstart,
    }
  }

  # array syntax isn't working (solr_config { $config::envs: }) ; i'm probably just an idiot
  if 'main' in $config::envs {
    # clone the project
    project_unisubs { 'main': revision => 'dev', }
  }
  if 'local' in $config::envs {
    # clone the project
    project_unisubs { 'local': revision => 'staging', }
  }
  if 'dev' in $config::envs {
    # clone the project
    project_unisubs { 'dev': }
  }
  if 'staging' in $config::envs {
    # clone the project
    project_unisubs { 'staging': }
  }
  if 'production' in $config::envs {
    # clone the project
    project_unisubs { 'production': }
  }

}