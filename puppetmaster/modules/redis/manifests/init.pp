# == Class: redis
#
# Installs and configures redis
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  class { redis: }
#    or
#  include redis
#
# === Authors
#
# Amara <dev@pculture.org>
#
# === Copyright
#
# Copyright 2012 PCF, unless otherwise noted.
#
class redis (
    $redis_user=$redis::params::redis_user,
    $data_dir=$redis::params::data_dir,
    $log_dir=$redis::params::log_dir,
  ) inherits redis::params {

  class { 'redis::package': }
  class { 'redis::config':
    require => Class['redis::package'],
  }
  class { 'redis::service':
    require => [ Class['redis::config'], Class['redis::package'] ],
  }
}
