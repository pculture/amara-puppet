# == Class: config
#
# Configuration for Amara
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  class { config: }
#    or
#  include config
#
# === Authors
#
# Amara <dev@pculture.org>
#
# === Copyright
#
# Copyright 2012 PCF, unless otherwise noted.
#
class config {
  $env = "${::system_env}"
  $roles = $::system_roles
  # conditional to check for roles
  if 'app' in $roles {
    include config::roles::app
  }
  if 'data' in $roles {
    include config::roles::data
  }
  if 'util' in $roles {
    include config::roles::util
  }
  if 'local' in $roles {
    include config::roles::local
  }
}
