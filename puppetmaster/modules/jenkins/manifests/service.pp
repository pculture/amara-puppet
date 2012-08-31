class jenkins::service inherits jenkins::params {
  service { 'jenkins': ensure => running, }
}
