# == Class: sensu
#
# Installs and configures sensu
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  class { sensu: }
#    or
#  include sensu
#
# === Authors
#
# Amara <dev@pculture.org>
#
# === Copyright
#
# Copyright 2012 PCF, unless otherwise noted.
#
class sensu (
  $sensu_rabbitmq_host=$sensu::params::sensu_rabbitmq_host,
  $sensu_rabbitmq_port=$sensu::params::sensu_rabbitmq_port,
  $sensu_rabbitmq_vhost=$sensu::params::sensu_rabbitmq_vhost,
  $sensu_rabbitmq_user=$sensu::params::sensu_rabbitmq_user,
  $sensu_rabbitmq_pass=$sensu::params::sensu_rabbitmq_pass,
  $sensu_redis_host=$sensu::params::sensu_redis_host,
  $sensu_redis_port=$sensu::params::sensu_redis_port,
  $sensu_api_host=$sensu::params::sensu_api_host,
  $sensu_api_port=$sensu::params::sensu_api_port,
  $sensu_dashboard_host=$sensu::params::sensu_dashboard_host,
  $sensu_dashboard_port=$sensu::params::sensu_dashboard_port,
  $sensu_dashboard_user=$sensu::params::sensu_dashboard_user,
  $sensu_dashboard_pass=$sensu::params::sensu_dashboard_pass,
  ) inherits sensu::params {
  class { 'sensu::package': }
  class { 'sensu::client': }
  class { 'sensu::config':
    require => Class['sensu::package'],
  }
}
