class rabbitmq::package {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }

  # get apt key
  exec { 'rabbitmq::package::apt_key':
    command => 'wget -q http://www.rabbitmq.com/rabbitmq-signing-key-public.asc -O- | sudo apt-key add -',
    user    => root,
    unless  => 'apt-key list | grep -i rabbitmq',
  }
  file { '/etc/apt/sources.list.d/rabbitmq.list':
    alias   => 'rabbitmq::package::apt_source_list',
    ensure  => present,
    content => "deb http://www.rabbitmq.com/debian/ testing main\n",
    owner   => root,
    notify  => Exec['rabbitmq::package::apt_update'],
    require => Exec['rabbitmq::package::apt_key'],
  }
  exec { 'rabbitmq::package::apt_update':
    command     => 'apt-get update',
    user        => root,
    refreshonly => true,
  }
  if ! defined(Package["rabbitmq-server"]) {
    package { "rabbitmq-server":
      ensure  => installed,
      require => [ File['rabbitmq::package::apt_source_list'], Exec['rabbitmq::package::apt_update'] ],
    }
  }

}
