# Puppet Module :: Appserver

This installs and configures various application servers (currently python and nodejs).

## Usage

Basic (will support python and nodejs)

`include appserver`

Parameters

```
class { 'appserver':
  python => true,
  nodejs => false,
} 
```