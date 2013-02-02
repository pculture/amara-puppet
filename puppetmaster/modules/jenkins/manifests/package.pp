class jenkins::package inherits jenkins::params {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  # get apt key
  exec { 'jenkins::package::apt_key':
    command => 'wget --no-check-certificate -q http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key -O- | sudo apt-key add -',
    user    => root,
    unless  => 'apt-key list | grep -i kawaguchi',
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
  file { '/var/lib/jenkins/plugins':
    alias   => 'jenkins::package::plugin_dir',
    ensure  => directory,
    owner   => 'jenkins',
    require => Package['jenkins']
  }
  define install_plugin ($url=$title) {
    $file_parts = split($url, 'latest/')
    $filename = $file_parts[1]
    exec { "jenkins::package::install_plugin_$url":
      cwd     => '/var/lib/jenkins/plugins',
      command => "wget --no-check-certificate -q $url",
      creates => "/var/lib/jenkins/plugins/$filename",
      user    => 'jenkins',
      require => [ Package['jenkins'], File['jenkins::package::plugin_dir'] ],
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
      $jenkins::params::postbuildtask_plugin_url,
      $jenkins::params::sauce_ondemand_plugin_url,
      $jenkins::params::copy_to_slave_plugin_url,
    ]
    install_plugin { $plugins: }
  }
}
