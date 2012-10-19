# == Class: solr
#
# Installs and configures solr
#
# === Parameters
#
# configure
#   This will configure Solr users and cores
#
# === Variables
#
# === Examples
#
#  class { solr: }
#    or
#  include solr
#
# === Authors
#
# Amara <dev@pculture.org>
#
# === Copyright
#
# Copyright 2012 PCF, unless otherwise noted.
#
class solr ($configure=true, $manage_cores=true,
  ) inherits solr::params {

  class { 'solr::package': }
  class { 'solr::config':
    require => Class['solr::package'],
  }
  class { 'solr::service':
    require => [ Class['solr::config'], Class['solr::package'] ],
  }
}
