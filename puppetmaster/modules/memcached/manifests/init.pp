# == Class: memcached
#
# Installs and configures memcached
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  class { memcached: }
#    or
#  include memcached
#
# === Authors
#
# Amara <dev@pculture.org>
#
# === Copyright
#
# Copyright 2012 PCF, unless otherwise noted.
#
class memcached {
  class { 'memcached::package': }
  class { 'memcached::config':
    require => Class['memcached::package'],
  }
  class { 'memcached::service':
    require => [ Class['memcached::config'], Class['memcached::package'] ],
  }
}
