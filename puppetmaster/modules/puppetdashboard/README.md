# Puppet Module :: Puppet Dashboard

This installs and configures the Puppet Dashboard.

## Usage

Basic

`include puppetdashboard`

Parameters

```
class { 'puppetdashboard':
  dashboard_db_name     => 'mydashboard',
  dashboard_db_username => 'foouser',
  dashboard_db_password => 'bar',
}
```