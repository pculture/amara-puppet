# Amara Puppet

Configuration management for Amara

# Overview

Vagrant is used to build the entire environment.  A Vagrant config is used for the Puppet master as well as another multi-VM config for the nodes.

## Puppet Master

The `puppetmaster` directory contains the Puppet manifests and modules.  The vagrant file will build a Puppet master server.

### Setup

`vagrant up`

Vagrant will import (if necessary), boot, and configure the Puppet master.  Port forwarding is configured for the VM for ports 3000 (puppet dashboard) and 8140 (puppet).  Once finished, you can access the Puppet Dashboard via http://localhost:3000/.

### Application setup

To test the Amara application locally, create an entry in your local `/etc/hosts` with the following:

`10.10.10.115    unisubs.local`

This will use the local multi-VM application server.

*Note: You must use `unisubs.local` as the media URLs are setup for that hostname.

## Nodes

Node (server or VM) functionality is divided into "roles" such as `app`, `data`, `util`, etc.  A node may have one or more roles that are defined in YAML format in the file `/etc/system_roles.yml`.

For example:

```yaml
roles:
  - app
```

Each role defines multiple Puppet modules that get applied to the instance.

For setup, there is a multi-VM Vagrant file that contains VM definitions for each role.

### Role: app

The `app` role contains the `appserver` and `nginx` modules.  It will setup an application server powered by uWSGI and Nginx.  Port forwarding is setup for port 8080 and 8000 to the instance.

To start an `app` instance:

`vagrant up app`

### Role: data

The `data` role contains the `rabbitmq`, `redis`, and `solr` modules.  Port forwarding is setup on ports 5672 (RabbitMQ), 6379 (Redis), and 8989 (Solr).

To start a `data` instance:

`vagrant up data`

### Role: util

The `util` role contains the `graylog2` module for centralized syslogging.  Every node is also configured to forward logs to this instance.  Port forwarding is setup for port 3001 to access the Graylog2 web interface.  To access it, visit http://localhost:3001/ .

To start a `util` instance:

`vagrant up util`

### Role: jenkins

The `jenkins` role contains the `jenkins` module for continuous integration testing.  Port forwarding is setup for port 8888 to access the Jenkins web interface.  To access it, visit http://localhost:8888/ .

To start a `jenkins` instance:

`vagrant up jenkins`

## Environments

The node environment(s) (dev, staging, production) are defined in the file `/etc/system_environments.yml`.

For example:
```yaml
environments:
  - dev
```

# Appendix

## General Notes

In order to do full multi-VM replicated environment testing, you will need the `amara-puppet-private` module.  See below for details.  However, you can still build an entire environment (everything but serving the app on http://unisubs.local) without the `amara-puppet-private` module.

## Adding a new environment (for the `app` role)

To add a new environment for the `app` role:

* Add another role check in config/manifests/roles/app.pp (see existing)
  * Note: by default, the `unisubs` module will try to do a checkout to the environment name (dev, staging, etc.).  To use a different revision, set it in the role check for the `project_unisubs` definition.  For example: `project_unisubs {'myenv': revision => 'my-custom-rev',}`
* Add another role check in amara-puppet-private/manifests/init.pp (see existing)
* Add the appropriate configuration options for the environment in amara-puppet-private/manifests/config.pp (see existing)

## Amara Config
In order to use the private Amara config, clone the amara-puppet-private repo into the `puppetmaster` directory.  The Vagrantfile will automatically mount the module in the proper place.

## VMware Fusion
VirtualBox has not been the most stable for me so I use VMware Fusion when VirtualBox is not playing nice.  In order to maintain consistency, I use the same networking for the VMs.  I will put the configuration process here and hopefully have a script to set it all up sometime.

* (on Mac) Edit /Library/Preferences/VMware\ Fusion/networking and configure NAT address subnet for 10.10.10.0 (should be VNET_8_HOSTONLY_SUBNET)
* Create each VM (following the Vagrantfile base OS - either Ubuntu lucid or precise)
* Install VMware tools
* Install Puppet (using the PuppetLabs APT repo http://projects.puppetlabs.com/projects/puppet/wiki/Downloading_Puppet#Ubuntu+Packages)
* Configure each VM networking (following the Vagrantfile for each node)
* On the Puppet master, `cd` into the shared directory and run the `build.sh` script to build the master
* Add a shared folder for the Puppet master to the `amara-puppet/puppetmaster` directory labeled as `puppet`
* To use the Amara Puppet modules add the following to `/etc/rc.local` before the `exit 0` line:

```
while [ "`mount | grep hgfs`" = "" ]
do
    sleep 5
done
mount -o bind /mnt/hgfs/puppet/manifests /etc/puppet/manifests
mount -o bind /mnt/hgfs/puppet/modules /etc/puppet/modules
mount -o bind /mnt/hgfs/puppet/amara-puppet-private/amara /etc/puppet/modules/amara
```
* Then run `sudo mount -a` to bind mount
* Run Puppet on each -- should setup the same environment
