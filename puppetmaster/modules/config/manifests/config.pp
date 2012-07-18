class config::config inherits config::params {
  $roles = $::system_roles ? {
    undef => [],
    default => $::system_roles,
  }
  if ($::is_vagrant == 'true') and ($roles == []) {
    include config::projects::unisubs
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
}
