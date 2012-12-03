# == Class: denyhosts
#
# Installs and configures denyhosts
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  class { denyhosts: }
#    or
#  include denyhosts
#
# === Authors
#
# Amara <dev@pculture.org>
#
# === Copyright
#
# Copyright 2012 PCF, unless otherwise noted.
#
class denyhosts {
  class { 'denyhosts::package': }
  class { 'denyhosts::config':
    require => Class['denyhosts::package'],
  }
  class { 'denyhosts::service':
    require => [ Class['denyhosts::config'], Class['denyhosts::package'] ],
  }
}
