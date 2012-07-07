# == Class: nginx
#
# Installs and configures nginx
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  class { nginx: }
#    or
#  include nginx
#
# === Authors
#
# Amara <dev@pculture.org>
#
# === Copyright
#
# Copyright 2012 PCF, unless otherwise noted.
#
class nginx (
  ) inherits nginx::params {

  class { 'nginx::package': }
  class { 'nginx::config':
    require => Class['nginx::package'],
  }
  class { 'nginx::service':
    require => [ Class['nginx::config'], Class['nginx::package'] ],
  }
}
