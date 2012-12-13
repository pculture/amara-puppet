class nginx::config inherits nginx::params {
  $www_user = 'www-data'
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  file { '/etc/nginx/nginx.conf':
    ensure  => present,
    content => template('nginx/nginx.conf.erb'),
    owner   => root,
    mode    => 0644,
    require => Package['nginx-extras'],
    notify  => Service['nginx'],
  }
  file { '/etc/nginx/sites-available/default':
    ensure  => present,
    content => template('nginx/default.conf.erb'),
    owner   => root,
    mode    => 0644,
    require => Package['nginx-extras'],
    notify  => Service['nginx'],
  }
}
