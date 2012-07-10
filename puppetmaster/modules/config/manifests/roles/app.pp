class config::roles::app {
  include nginx
  class { 'appserver':
    python  => true,
    nodejs  => false,
    require => Class['nginx'],
  }
  include closure

  class { 'config::config':
    require => [
      Class['appserver'],
      Class['nginx'],
      Class['closure'],
    ],
  }
}