class config::roles::data($revisions={}) {
  # base modules to include
  if ! defined(Class['memcached']) { class { 'memcached': } }
  if ! defined(Class['rabbitmq']) { class { 'rabbitmq': } }
  if ! defined(Class['redis']) { class { 'redis': } }
  if ! defined(Class['solr']) { class { 'solr': } }
  if ! defined(Class['virtualenv']) { class { 'virtualenv': } }
  # extra role packages
  if ! defined(Package['carrot-top']) { package { 'carrot-top': ensure => installed, provider => 'gem', require => Package['rubygems'], } }
  if ! defined(Package['libmysqlclient-dev']) { package { 'libmysqlclient-dev': ensure => installed, } }

  # if running in the local test vagrant multi-vm, include mysql for local testing
  if ($::is_vagrant == 'true') {
    if ! defined(Class['mysql']) { class { 'mysql': } }
  }
  if 'worker-only' in $config::params::roles {
    $enable_celery = false
  } else {
    $enable_celery = true
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
      enable_celery   => $enable_celery,
      require         => Class['virtualenv'],
    }
  }
  # setup unisubs project
  if 'local' in $config::envs {
    project_unisubs_data { 'local': revision => $revisions['local'], }
  }
  if 'dev' in $config::envs {
    project_unisubs_data { 'dev': revision => $revisions['dev'], }
  }
  if 'staging' in $config::envs {
    project_unisubs_data { 'staging': revision => $revisions['staging'], }
  }
  if 'nf' in $config::envs {
    project_unisubs_data { 'nf': revision => $revisions['nf'], }
  }
  if 'production' in $config::envs {
    project_unisubs_data { 'production': revision => $revisions['production'], }
  }
}
