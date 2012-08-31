class jenkins::config inherits jenkins::params {
  $port = $jenkins::port
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  file { '/etc/default/jenkins':
    alias   => 'jenkins::config::jenkins_conf',
    content => template('jenkins/jenkins.erb'),
    owner   => root,
    group   => root,
    mode    => 0644,
    require => Package['jenkins'],
    notify  => Service['jenkins'],
  }
}
