# Amara Puppet

Configuration management for Amara

# Overview

Vagrant is used to build the entire environment.  A Vagrant config is used for the Puppet master as well as another multi-VM config for the nodes.

## Puppet Master

The `puppetmaster` directory contains the Puppet manifests and modules.  The vagrant file will build a Puppet master server.

### Setup

`vagrant up`

Vagrant will import (if necessary), boot, and configure the Puppet master.  Port forwarding is configured for the VM for ports 3000 (puppet dashboard) and 8140 (puppet).  Once finished, you can access the Puppet Dashboard via http://localhost:3000/.

## Nodes

Node (server or VM) functionality is divided into "roles" such as `app`, `data`, `util`, etc.  A node may have one or more roles that are defined in YAML format in the file `/etc/system_roles.yml`.  Each role defines multiple Puppet modules that get applied to the instance.

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

The node environment (dev, staging, prod) is defined in the file `/etc/system_env`.
