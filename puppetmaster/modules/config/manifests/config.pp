class config::config inherits config::params {
  $project_dir = "${appserver::app_dir}/unisubs"

  if ($::virtual == 'virtualbox') {
    user { 'vagrant':
      ensure  => present,
    }
    file { 'config::config::vagrant_bashrc':
      ensure  => present,
      path    => '/home/vagrant/.bashrc',
      content => template('config/bashrc.erb'),
      owner   => 'vagrant',
      group   => 'vagrant',
      mode    => 0644,
      require => User['vagrant'],
    }
  }
  # custom role configs
  # app role
  if 'app' in $config::roles {
    require closure
    # unisubs closure library link
    file { 'config::config::unisubs_closure_library_link':
      ensure  => link,
      path    => "${config::config::project_dir}/media/js/closure-library",
      target  => "${closure::closure_local_dir}",
      require => Class['closure'],
    }
  }
}
