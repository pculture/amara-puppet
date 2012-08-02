# == Class: postfix
#
# Installs and configures postfix
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  class { postfix: }
#    or
#  include postfix
#
# === Authors
#
# Amara <dev@pculture.org>
#
# === Copyright
#
# Copyright 2012 PCF, unless otherwise noted.
#
class postfix () inherits postfix::params {

  class { 'postfix::package': }
  class { 'postfix::config':
    require => Class['postfix::package'],
  }
  class { 'postfix::service':
    require => [ Class['postfix::config'], Class['postfix::package'] ],
  }
}
