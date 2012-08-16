# == Class: riemann
#
# Installs and configures riemann
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  class { 'riemann': }
#    or
#  include riemann
#
# === Authors
#
# Amara <dev@pculture.org>
#
# === Copyright
#
# Copyright 2012 PCF, unless otherwise noted.
#
class riemann (
  $graphite_host=$riemann::params::graphite_host,
  $enable_dashboard=true,
  ) inherits riemann::params {
  class { 'riemann::package': }
  class { 'riemann::config':
    require => Class['riemann::package'],
  }
}
