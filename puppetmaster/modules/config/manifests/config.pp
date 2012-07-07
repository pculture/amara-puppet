class config::config inherits config::params {
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
}
