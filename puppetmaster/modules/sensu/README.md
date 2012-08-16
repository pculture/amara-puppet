# Puppet Module :: Sensu

This installs and configures Sensu.

By default this will install Sensu and configure the client.

## Usage

### Basic

`class { 'sensu': }`

### Parameters

* sensu_rabbitmq_host = 'localhost'
* sensu_rabbitmq_port = '5672'
* sensu_rabbitmq_vhost = '/sensu'
* sensu_rabbitmq_user = 'sensu'
* sensu_rabbitmq_pass = 's3n5u'
* sensu_redis_host = 'localhost'
* sensu_redis_port = '6379'
* sensu_api_host = 'localhost'
* sensu_api_port = '4567'
* sensu_dashboard_host = 'localhost'
* sensu_dashboard_port = '8080'
* sensu_dashboard_user = 'admin'
* sensu_dashboard_pass = 'sensu'

Example using custom RabbitMQ and Redis:

```
class { 'sensu':
  sensu_rabbitmq_host => 'myhost',
  sensu_rabbitmq_user => 'myuser',
  sensu_rabbitmq_pass => 'mypass',
  sensu_redis_host    => 'myredis',
}
```
## Server

To enable the Sensu server (api, server, dashboard).  This will install Sensu, RabbitMQ, and Redis.

`class { 'sensu::server': }`

### Parameters

* configure_rabbitmq = true
* configure_redis = true

  To skip installing and configuring RabbitMQ and Redis:

```
class { 'sensu::server':
  configure_rabbitmq => false,
  configure_redis    => false,
}
```
