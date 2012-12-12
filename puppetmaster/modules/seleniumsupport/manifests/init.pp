# == Class: seleniumsupport
#
# Installs additional packages, etc. for Selenium testing
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  class { seleniumsupport: }
#    or
#  include seleniumsupport
#
# === Authors
#
# Amara <dev@pculture.org>
#
# === Copyright
#
# Copyright 2012 PCF, unless otherwise noted.
#
class seleniumsupport {
  class { 'seleniumsupport::package': }
  class { 'seleniumsupport::config':
    require => Class['seleniumsupport::package'],
  }
  class { 'seleniumsupport::service':
    require => [ Class['seleniumsupport::config'], Class['seleniumsupport::package'] ],
  }
}
