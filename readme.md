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

## Environments

The node environment(s) (dev, staging, production) are defined in the file `/etc/system_environments.yml`.

For example:
```yaml
environments:
  - dev
```

# Appendix

## Adding a new environment (for the `app` role)

To add a new environment for the `app` role:

* Add another role check in config/manifests/roles/app.pp (see existing)
  * Note: by default, the `unisubs` module will try to do a checkout to the environment name (dev, staging, etc.).  To use a different revision, set it in the role check for the `project_unisubs` definition.  For example: `project_unisubs {'myenv': revision => 'my-custom-rev',}`
* Add another role check in amara-puppet-private/manifests/init.pp (see existing)
* Add the appropriate configuration options for the environment in amara-puppet-private/manifests/config.pp (see existing)

## Amara Config
In order to use the private Amara config, clone the amara-puppet-private repo into the `puppetmaster` directory.  The Vagrantfile will automatically mount the module in the proper place.
