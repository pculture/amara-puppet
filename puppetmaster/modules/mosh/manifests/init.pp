# == Class: mosh
#
# Installs and configures mosh
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  class { mosh: }
#    or
#  include mosh
#
# === Authors
#
# Amara <dev@pculture.org>
#
# === Copyright
#
# Copyright 2012 PCF, unless otherwise noted.
#
class mosh (
  ) inherits mosh::params {

  class { 'mosh::package': }
  class { 'mosh::config':
    require => Class['mosh::package'],
  }
  class { 'mosh::service':
    require => [ Class['mosh::config'], Class['mosh::package'] ],
  }
}
