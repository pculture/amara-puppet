#!/bin/sh

echo "10.10.10.100 puppet puppet.local" >> /etc/hosts
# create the env file
echo "dev" > /etc/system_env
# create the role file
echo "- role: `hostname -s`\n" > /etc/system_roles.yml

# run the initial sync in the foreground
puppet agent -t

exit 0
