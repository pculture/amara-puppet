# == Class: jenkins
#
# Installs and configures jenkins
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  class { jenkins: }
#    or
#  include jenkins
#
# === Authors
#
# Amara <dev@pculture.org>
#
# === Copyright
#
# Copyright 2012 PCF, unless otherwise noted.
#
class jenkins (
  $port=$jenkins::params::port,
  ) inherits jenkins::params {
  class { 'jenkins::package': }
  class { 'jenkins::config':
    require => Class['jenkins::package'],
  }
  class { 'jenkins::service':
    require => [ Class['jenkins::config'], Class['jenkins::package'] ],
  }
}
