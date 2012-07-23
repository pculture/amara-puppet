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
  $envs = $::system_environments
  $roles = $::system_roles ? {
    undef => [],
    default => $::system_roles,
  }
  # conditional to check for roles
  if 'app' in $roles {
    if ! defined(Class['config::roles::app']) { class { 'config::roles::app': } }
  }
  if 'data' in $roles {
    if ! defined(Class['config::roles::data']) { class { 'config::roles::data': } }
  }
  if 'util' in $roles {
    if ! defined(Class['config::roles::util']) { class { 'config::roles::util': } }
  }
  # local vagrant dev
  if 'vagrant' in $roles {
    if ! defined(Class['config::roles::app']) { class { 'config::roles::app': } }
    if ! defined(Class['config::roles::data']) { class { 'config::roles::data': } }
    if ! defined(Class['mysql']) { class { 'mysql': } }
  }
  # config
  if ! defined(Class['config']) { class { 'config::config': } }
}
