# == Class: virtualenv
#
# Installs virtualenv
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  class { 'virtualenv': }
#    or
#  include virtualenv
#
# === Authors
#
# Amara <dev@pculture.org>
#
# === Copyright
#
# Copyright 2012 PCF, unless otherwise noted.
#
class virtualenv {
  class { 'virtualenv::package': }
}
