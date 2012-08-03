class config::roles::data {
  # base modules to include
  if ! defined(Class['rabbitmq']) { class { 'rabbitmq': } }
  if ! defined(Class['redis']) { class { 'redis': } }
  if ! defined(Class['solr']) { class { 'solr': } }
  if ! defined(Class['virtualenv']) { class { 'virtualenv': } }
  if ! defined(Class['config::config']) {
    class { 'config::config':
      require => [
        Class['rabbitmq'],
        Class['redis'],
        Class['solr'],
      ],
    }
  }
  # extra role packages
  if ! defined(Package['libmysqlclient-dev']) { package { 'libmysqlclient-dev': ensure => installed, } }

  # if running in the local test vagrant multi-vm, include mysql for local testing
  if ($::is_vagrant) {
    if ! defined(Class['mysql']) { class { 'mysql': } }
  }

  define project_unisubs_data ($revision=undef, $enable_upstart=false, $env=$name) {
    #$apps_root  = "$config::apps_dir"
    $app_group     = "$config::app_group"
    #$ve_root       = "$config:ve_root"
    config::projects::unisubs { "$name":
      #apps_root       => $apps_root,
      app_group       => $app_group,
      #ve_root         => $ve_root,
      revision        => $revision,
      env             => $env,
      enable_upstart  => $enable_upstart,
      require         => Class['virtualenv'],
    }
  }
  # setup unisubs project
  if 'local' in $config::envs {
    project_unisubs_data { 'local': revision => 'staging', }
  }
  if 'dev' in $config::envs {
    project_unisubs_data { 'dev': }
  }
  if 'staging' in $config::envs {
    project_unisubs_data { 'staging': }
  }
  if 'nf' in $config::envs {
    project_unisubs_data { 'nf': revision => 'x-nf', }
  }
  if 'production' in $config::envs {
    project_unisubs_data { 'production': }
  }
  # this is for the development environment
  if 'vagrant' in $config::envs {
    project_unisubs_data { 'vagrant': revision => 'dev', }
  }
}
