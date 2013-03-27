define config::projects::unisubs (
    $repo='https://github.com/pculture/unisubs.git',
    $revision=undef,
    $apps_root='/opt/apps',
    $app_user='root',
    $app_group='root',
    $ve_root='/opt/ve',
    $enable_upstart=true,
    $env=undef,
    $enable_celery=true,
    $celery_user='celery',
    $celery_group='celery',
    $setup_db=false,
    $graphite_host=undef,
  ) {

  $hostname = $::hostname

  # modules
  if ! defined(Class['celery']) { class { 'celery': } }
  if ! defined(Class['closure']) { class { 'closure': } }
  if ! defined(Class['virtualenv']) { class { 'virtualenv': } }

  # supporting OS packages
  if ! defined(Package['git-core']) { package { 'git-core': ensure => installed, } }
  if ! defined(Package['python-dev']) { package { 'python-dev': ensure => installed, } }
  if ! defined(Package['python-imaging']) { package { 'python-imaging': ensure => installed, } }
  if ! defined(Package['python-memcache']) { package { 'python-memcache': ensure => installed, } }
  if ! defined(Package['libmysqlclient-dev']) { package { 'libmysqlclient-dev': ensure => installed, } }
  if ! defined(Package['libxml2-dev']) { package { 'libxml2-dev': ensure => installed, } }
  if ! defined(Package['libxslt1-dev']) { package { 'libxslt1-dev': ensure => installed, } }
  if ! defined(Package['swig']) { package { 'swig': ensure => installed, } }

  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }

  $roles = $::system_roles ? {
    undef => [],
    default => $::system_roles,
  }
  $settings_module = $env ? {
    'vagrant' => 'dev_settings',
    default   => 'unisubs_settings',
  }
  $rev = $revision ? {
    undef   => "${env}",
    default => $revision,
  }
  $server_name = "${env}" ? {
    'vagrant'    => 'unisubs.example.com',
    'local'       => 'unisubs.local amara.local', # this is for the multi-vm environment for infrastructure testing
    'production'  => 'www.universalsubtitles.org universalsubtitles.org www.amara.org amara.org',
    default       => "${env}.universalsubtitles.org ${env}.amara.org",
  }
  $project_root = "${apps_root}/${env}"
  $project_dir = "${project_root}/unisubs"
  $ve_dir = "${ve_root}/${env}/unisubs"

  # app root
  if ! defined(File["${apps_root}"]) { file { "${apps_root}": ensure => directory, path => "${apps_root}", } }

  # don't setup project dir for vagrant ; it's symlinked via vagrant
  if ($env != 'vagrant') {
    file { "config::projects::unisubs::project_root_${env}":
      ensure  => directory,
      path    => "$project_root",
      owner   => "$app_user",
      group   => "$app_group",
      mode    => 2775,
    }
    cron { "config::project::unisubs::cron_app_dir_permissions_${env}":
      command   => "chown -R ${app_user}:${app_group} ${project_dir} ; chmod -R g+rw ${project_dir}",
      user      => root,
      hour      => '*',
      minute    => '05',
    }
    # unisubs repo
    exec { "config::projects::unisubs::clone_repo_${env}":
      command => "git clone ${repo} ${project_dir}",
      user    => "${app_user}",
      creates => "${project_dir}",
      timeout => 900,
      require => [ Package['git-core'], File["config::projects::unisubs::project_root_${env}"] ],
    }
    exec { "config::projects::unisubs::set_permissions_${env}":
      command     => "chown -R ${app_user}:${app_group} ${project_dir} ; chmod -R g+rw ${project_dir}",
      require     => Exec["config::projects::unisubs::clone_repo_${env}"],
      refreshonly => true,
    }
    # unisubs closure library link
    file { "config::projects::unisubs::unisubs_closure_library_link_${env}":
      ensure  => link,
      path    => "${project_dir}/media/js/closure-library",
      target  => "${closure::closure_local_dir}",
      require => [Exec["config::projects::unisubs::clone_repo_${env}"], Class['closure'] ],
    }
    # create virtualenv
    exec { "config::projects::unisubs::virtualenv_${env}":
      command     => "virtualenv --no-site-packages ${ve_dir}",
      creates     => "${ve_dir}",
      require     => Class['virtualenv'],
      notify      => Exec["config::projects::unisubs::bootstrap_ve_${env}"],
    }
    exec { "config::projects::unisubs::bootstrap_ve_${env}":
      command     => "${ve_dir}/bin/pip install -r requirements.txt",
      cwd         => "${project_dir}/deploy",
      require     => Exec["config::projects::unisubs::clone_repo_${env}"],
      timeout     => 1200,
      refreshonly => true,
      notify      => Exec["config::projects::unisubs::ve_permissions_${env}"],
    }
    # upstart
    if $enable_upstart {
      file { "config::projects::unisubs::uwsgi_unisubs_conf_${env}":
        ensure  => present,
        path    => "/etc/uwsgi.unisubs.${env}.ini",
        content => template('config/apps/unisubs/uwsgi.unisubs.ini.erb'),
        mode    => 0644,
        owner   => root,
        notify  => Service["uwsgi.unisubs.${env}"],
      }
      file { "config::projects::unisubs::upstart_unisubs_${env}":
        ensure  => present,
        path    => "/etc/init/uwsgi.unisubs.${env}.conf",
        content => template('config/apps/unisubs/upstart.unisubs.uwsgi.conf.erb'),
        mode    => 0644,
        owner   => root,
      }
      # manual symlink to /lib/init/upstart-job for http://projects.puppetlabs.com/issues/14297
      file { "config::projects::unisubs::upstart_link_unisubs_${env}":
        ensure  => link,
        path    => "/etc/init.d/uwsgi.unisubs.${env}",
        target  => '/lib/init/upstart-job',
        require => File["config::projects::unisubs::upstart_unisubs_${env}"],
      }
      service { "uwsgi.unisubs.${env}":
        enable    => true,
        ensure    => running,
        provider  => 'upstart',
        require   => [ File["config::projects::unisubs::upstart_link_unisubs_${env}"], Exec["config::projects::unisubs::bootstrap_ve_${env}"] ],
      }
    }
  } else {
    # these are duplicated from above to change requires so the local
    # dev environment that is symlinked from vagrant doesn't get touched
    # unisubs closure library link
    file { "config::projects::unisubs::unisubs_closure_library_link_${env}":
      ensure  => link,
      path    => "${project_dir}/media/js/closure-library",
      target  => "${closure::closure_local_dir}",
      require => Class['closure'],
    }
    # create virtualenv
    exec { "config::projects::unisubs::virtualenv_${env}":
      command   => "virtualenv --no-site-packages ${ve_dir} ; chown -R ${app_user} ${ve_dir}",
      user      => root,
      creates   => "${ve_dir}",
      require   => Class['virtualenv'],
      notify    => Exec["config::projects::unisubs::ve_permissions_${env}"],
    }
  }
  exec { "config::projects::unisubs::ve_permissions_${env}":
    command     => "chgrp -R ${app_group} ${ve_dir} ; chmod -R g+rw ${ve_dir}",
    refreshonly => true,
  }
  # local email dir
  file { "config::projects::unisubs::email_messages_dir_${env}":
    ensure  => directory,
    path    => "/tmp/unisubs-messages_${env}",
    owner   => "${app_user}",
    group   => "${app_group}",
    mode    => 0770,
  }
  if ($enable_celery) {
    # celery config
    file { "config::projects::unisubs::upstart_celeryd_conf_${env}":
      ensure  => present,
      path    => "/etc/init/celeryd.${env}.conf",
      content => template('config/apps/unisubs/upstart.celeryd.conf.erb'),
      owner   => root,
      group   => root,
      mode    => 0644,
    }
    # manual symlink to /lib/init/upstart-job for http://projects.puppetlabs.com/issues/14297
    file { "config::projects::unisubs::upstart_link_celeryd_${env}":
      ensure  => link,
      path    => "/etc/init.d/celeryd.${env}",
      target  => '/lib/init/upstart-job',
      require => File["config::projects::unisubs::upstart_celeryd_conf_${env}"],
    }
    service { "celeryd.${env}":
      enable    => true,
      ensure    => running,
      require   =>[ Class['celery'], File["config::projects::unisubs::upstart_link_celeryd_${env}"] ]
    }
    file { "config::projects::unisubs::upstart_celerycam_conf_${env}":
      ensure  => present,
      path    => "/etc/init/celerycam.${env}.conf",
      content => template('config/apps/unisubs/upstart.celerycam.conf.erb'),
      owner   => root,
      group   => root,
      mode    => 0644,
    }
    # manual symlink to /lib/init/upstart-job for http://projects.puppetlabs.com/issues/14297
    file { "config::projects::unisubs::upstart_link_celerycam_${env}":
      ensure  => link,
      path    => "/etc/init.d/celerycam.${env}",
      target  => '/lib/init/upstart-job',
      require => File["config::projects::unisubs::upstart_celerycam_conf_${env}"],
    }
    service { "celerycam.${env}":
      enable    => true,
      ensure    => running,
      require   =>[ Class['celery'], File["config::projects::unisubs::upstart_link_celerycam_${env}"] ]
    }
    # logrotate for celery
    file { '/etc/logrotate.d/celery':
      ensure    => present,
      content   => template('config/apps/unisubs/celery.logrotate.erb'),
      owner     => root,
      group     => root,
      mode      => 0644,
    }
    # disabled for now as upstart doesn't like symlinks
    ## symlinks for celery - needed for celery module (celeryd, celerybeat)
    ## NOTE: on multi-env setups, this will only be created for the first env as subsequent
    ## ones would just overwrite the symlink
    #if ! defined(File['config::projects::unisubs::celeryd_symlink']) {
    #  file { "config::projects::unisubs::celeryd_symlink":
    #    ensure    => link,
    #    path      => '/etc/init/celeryd.conf',
    #    target    => "/etc/init/celeryd.$env.conf",
    #    require   => File["config::projects::unisubs::upstart_celeryd_conf_$env"],
    #  }
    #}
    #if ! defined(File['config::projects::unisubs::celerycam_symlink']) {
    #  file { "config::projects::unisubs::celerycam_symlink":
    #    ensure    => link,
    #    path      => '/etc/init/celerycam.conf',
    #    target    => "/etc/init/celerycam.$env.conf",
    #    require   => File["config::projects::unisubs::upstart_celerycam_conf_$env"],
    #  }
    #}
  }
  # nginx ; only create virtual host if class is defined
  if defined(Class['nginx']) {
    file { "config::projects::unisubs::vhost_unisubs_${env}":
      path    => "/etc/nginx/conf.d/amara_${env}.conf",
      content => template('config/apps/unisubs/vhost_unisubs.conf.erb'),
      #owner   => "${nginx::config::www_user}",
      mode    => 0644,
      require => Package['nginx-extras'],
      notify  => Service['nginx'],
    }
  }
  # vagrant setup
  if ($::is_vagrant == 'true') and ($env == 'vagrant') {
    # vagrant vagrant setup
    #user { 'vagrant':
    #  ensure  => present,
    #}
    $vagrant_home = $::virtual ? {
      default   => '/home/vagrant',
    }
    file { 'config::projects::unisubs::vagrant_bashrc':
      ensure  => present,
      path    => "${vagrant_home}/.bashrc",
      content => template('config/apps/unisubs/bashrc.erb'),
      owner   => 'vagrant',
      group   => 'vagrant',
      mode    => 0644,
      #require => User['vagrant'],
    }
    file { 'config::projects::unisubs::vagrant_grcat':
      ensure  => directory,
      path    => "${vagrant_home}/.grc",
      owner   => 'vagrant',
      group   => 'vagrant',
      mode    => 0755,
      #require => User['vagrant'],
    }
    file { 'config::projects::unisubs::vagrant_grcat_pmt_config':
      ensure  => present,
      path    => "${vagrant_home}/.grc/conf.pmt",
      content => template('config/apps/unisubs/conf.pmt.erb'),
      owner   => 'vagrant',
      group   => 'vagrant',
      mode    => 0644,
      require => File['config::projects::unisubs::vagrant_grcat'],
    }
    file { 'config::projects::unisubs::vagrant_grcat_pmm_config':
      ensure  => present,
      path    => "${vagrant_home}/.grc/conf.pmm",
      content => template('config/apps/unisubs/conf.pmm.erb'),
      owner   => 'vagrant',
      group   => 'vagrant',
      mode    => 0644,
      require => File['config::projects::unisubs::vagrant_grcat'],
    }
    file { 'config::projects::unisubs::vagrant_xvfb_upstart':
      ensure  => present,
      path    => '/etc/init/xvfb.conf',
      source  => 'puppet:///modules/config/xvfb.conf',
    }
    # manual symlink to /lib/init/upstart-job for http://projects.puppetlabs.com/issues/14297
    file { 'config::projects::unisubs::upstart_link_xvfb':
      ensure  => link,
      path    => '/etc/init.d/xvfb',
      target  => '/lib/init/upstart-job',
      require => File['config::projects::unisubs::vagrant_xvfb_upstart'],
    }
    # # nginx
    #     file { 'config::projects::unisubs::vhost_unisubs_vagrant':
    #       path    => '/etc/nginx/conf.d/unisubs.example.com.conf',
    #       content => template('config/apps/unisubs/vhost_unisubs.conf.erb'),
    #       #owner   => "${nginx::config::www_user}",
    #       mode    => 0644,
    #       require => Package['nginx-extras'],
    #       notify  => Service['nginx'],
    #     }
  }

}
