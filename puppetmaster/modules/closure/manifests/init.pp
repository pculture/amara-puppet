# == Class: closure
#
# Installs and configures the Closure Library
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  class { closure: }
#    or
#  include closure
#
# === Authors
#
# Amara <dev@pculture.org>
#
# === Copyright
#
# Copyright 2012 PCF, unless otherwise noted.
#
class closure (
    $closure_repo=$closure::params::closure_repo,
    $closure_revision=$closure::params::closure_revision,
    $closure_local_dir=$closure::params::closure_local_dir,
  ) inherits closure::params {
  class { 'closure::package': }
  class { 'closure::config':
    require => Class['closure::package'],
  }
}
