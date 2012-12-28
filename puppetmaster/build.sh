#!/bin/sh
#
#  Sets up the Puppet master
#

HOSTNAME=`hostname -s`
DOMAIN=`hostname -d`
HOSTNAME_FQDN=`hostname -f`
PUPPETLABS_DEB_URL='http://apt.puppetlabs.com/puppetlabs-release-precise.deb'

if [ "$(id -u)" != "0" ]; then echo "Error: You must be root to run setup" ; exit ; fi

if [ -e /usr/bin/puppet ]; then echo "Machine appears to be configured ; skipping provisioning..." ; exit ; fi

# update hosts
#sed -i 's/^127\.0\.0\.1\s+*/127\.0\.0\.1    localhost /g' /etc/hosts
#sed -i 's/^127\.0\.1\.1\s+*//g' /etc/hosts

cd /tmp

wget --quiet "${PUPPETLABS_DEB_URL}" -O puppetlabs.deb
dpkg -i puppetlabs.deb

apt-get -y update
DEBCONF=noninteractive apt-get -y install puppetmaster-passenger git-core python-software-properties

gem install --no-ri --no-rdoc hiera hiera-puppet

# create puppet directories
mkdir -p /etc/puppet/manifests
mkdir -p /etc/puppet/modules

# create initial puppet config
echo "[main]
  pluginsync = true

[master]
  allow_duplicate_certs = True
  node_name = facter
  ssldir = /var/lib/puppet/ssl

[agent]
  node_name_fact = fqdn
  runinterval = 300" > /etc/puppet/puppet.conf

# create hiera config
echo "---
:backends:
  - yaml
  - puppet

:logger: console

:hierarchy:
  - "%{system_environment}"
  - common

:yaml:
   :datadir: /etc/puppet/hieradata

:puppet:
   :datasource: data
" > /etc/hiera.yaml

# autosign config for vagrant
echo "*.local" > /etc/puppet/autosign.conf

chown -R puppet /etc/puppet

# symlink agent ssl dir to master to avoid conflicts
ln -sf /var/lib/puppet/ssl /etc/puppet/ssl

# restart passenger
service apache2 restart

mkdir -p /var/lib/puppet/log
chown -R puppet /var/lib/puppet
chmod -R 0750 /var/lib/puppet/log

# run initial sync
puppet agent -t

echo "Master setup complete."

