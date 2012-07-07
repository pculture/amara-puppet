# == Class: celery
#
# Installs and configures celery
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  class { celery: }
#    or
#  include celery
#
# === Authors
#
# Amara <dev@pculture.org>
#
# === Copyright
#
# Copyright 2012 PCF, unless otherwise noted.
#
class celery (
    $celery_user=$celery::params::celery_user,
    $celery_group=$celery::params::celery_group,
  ) inherits celery::params {

  class { 'celery::package': }
  class { 'celery::config':
    require => Class['celery::package'],
  }
  class { 'celery::service':
    require => [ Class['celery::config'], Class['celery::package'] ],
  }
}
