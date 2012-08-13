#!/bin/sh

echo "10.10.10.100 puppet puppet.local" >> /etc/hosts
# create the env file
echo "- local\n" > /etc/system_environments.yml
# create the role file
echo "- `hostname -s`\n" > /etc/system_roles.yml

# update apt
apt-get -y update 2>&1 > /dev/null

# create the initial puppet.conf ; needed to sync puppet role facts
mkdir -p /etc/puppet
echo "[main]\n  pluginsync = true\n" > /etc/puppet/puppet.conf
# run the initial sync in the foreground
puppet agent -t

exit 0
