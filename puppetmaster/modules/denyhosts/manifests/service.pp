class denyhosts::service inherits denyhosts::params {
  service { 'denyhosts': ensure => running, }
}
