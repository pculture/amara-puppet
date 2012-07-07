class closure::package {
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  if ! defined(Package['subversion']) { package { 'subversion': ensure => installed, } }

  exec { 'closure::package::install_closure':
    command => "svn checkout -r ${closure::closure_revision} ${closure::closure_repo} ${closure::closure_local_dir}",
    creates => "${closure::closure_local_dir}",
  }
}
