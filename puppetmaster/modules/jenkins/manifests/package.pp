class jenkins::package {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  # get apt key
  exec { 'jenkins::package::apt_key':
    command => 'wget -q http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key -O- | sudo apt-key add -',
    user    => root,
    unless  => 'apt-key list | grep -i jenkins',
  }
  file { '/etc/apt/sources.list.d/jenkins.list':
    alias   => 'jenkins::package::apt_source_list',
    ensure  => present,
    content => "deb http://pkg.jenkins-ci.org/debian binary/\n",
    owner   => root,
    notify  => Exec['jenkins::package::apt_update'],
    require => Exec['jenkins::package::apt_key'],
  }
  exec { 'jenkins::package::apt_update':
    command     => 'apt-get update',
    user        => root,
    refreshonly => true,
  }
  define install_plugin ($url=$title) {
    $filename = split($url, 'latest/')
    exec { "jenkins::package::install_plugin_$url":
      cwd     => '/var/lib/jenkins/plugins',
      command => "wget -q $url",
      creates => "/var/lib/jenkins/plugins/$filename[1]",
      user    => 'jenkins',
      require => Package['jenkins'],
      notify  => Service['jenkins'],
    }
  }
  if ! defined(Package["jenkins"]) {
    package { "jenkins":
      ensure  => installed,
      require => [ File['jenkins::package::apt_source_list'], Exec['jenkins::package::apt_update'] ],
    }
    $plugins = [
      $jenkins::params::cobertura_plugin_url,
      $jenkins::params::git_plugin_url,
      $jenkins::params::greenballs_plugin_url,
      $jenkins::params::instantmessaging_plugin_url,
      $jenkins::params::ircbot_plugin_url,
    ]
    install_plugin { $plugins: }
  }
}
