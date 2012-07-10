class config::config inherits config::params {
  $roles = $::system_roles ? {
    undef => [],
    default => $::system_roles,
  }
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
  if 'app' in $config::config::roles {
    include config::projects::unisubs
  }
}
