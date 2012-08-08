# == Class: graphite
#
# Installs and configures graphite
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  class { 'graphite': }
#    or
#  include graphite
#
# === Authors
#
# Amara <dev@pculture.org>
#
# === Copyright
#
# Copyright 2012 PCF, unless otherwise noted.
#
class graphite {
  class { 'graphite::package': }
  class { 'graphite::config':
    require => Class['graphite::package'],
  }
  class { 'graphite::service':
    require => [
      Class['graphite::package'],
      Class['graphite::config'],
    ],
  }
}
