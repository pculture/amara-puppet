# == Class: apache
#
# Installs and configures apache
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  class { apache: }
#    or
#  include apache
#
# === Authors
#
# Amara <dev@pculture.org>
#
# === Copyright
#
# Copyright 2012 PCF, unless otherwise noted.
#
class apache {
  class { 'apache::package': }
  class { 'apache::config':
    require => Class['apache::package'],
  }
}
