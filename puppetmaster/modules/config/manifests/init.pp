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
class config (
    $apps_dir=$config::params::apps_dir,
    $ve_root=$config::params::ve_dir,
    $app_group=$config::params::app_group,
    $build_root=$config::params::build_root,
    $graphite_host=$config::params::graphite_host,
  ) inherits config::params {
  # this needs to match the appserver::apps_dir variable for the fabric tasks
  # hash for controlling revisions for the app and data roles
  $revisions = {
    'vagrant'     => 'dev',
    'local'       => 'staging',
    'dev'         => 'dev', # temporary
    'staging'     => 'staging',
    'nf'          => 'x-nf',
    'production'  => 'production',
  }
  # conditional to check for roles
  if 'app' in $config::params::roles {
    if ! defined(Class['config::roles::app']) {
      class { 'config::roles::app':
        graphite_host => $graphite_host,
        revisions     => $revisions,
      }
    }
  }
  if 'builder' in $config::params::roles {
    if ! defined(Class['config::roles::builder']) { class { 'config::roles::builder': } }
  }
  if 'data' in $config::params::roles {
    if ! defined(Class['config::roles::data']) {
      class { 'config::roles::data':
        revisions => $revisions,
      }
    }
  }
  if 'jenkins' in $config::params::roles {
    if ! defined(Class['config::roles::jenkins']) { class { 'config::roles::jenkins': } }
  }
  if 'lb' in $config::params::roles {
    if ! defined(Class['config::roles::lb']) { class { 'config::roles::lb': } }
  }
  if 'util' in $config::params::roles {
    if ! defined(Class['config::roles::util']) { class { 'config::roles::util': } }
  }
  # local vagrant dev
  if 'vagrant' in $config::params::roles {
    if ! defined(Class['config::roles::app']) { class { 'config::roles::app': } }
    if ! defined(Class['config::roles::data']) { class { 'config::roles::data': } }
    if ! defined(Class['mysql']) { class { 'mysql': } }
    if ! defined(Class['seleniumsupport']) { class { 'seleniumsupport': } }
  }
}
