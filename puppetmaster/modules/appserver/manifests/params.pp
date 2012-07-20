class appserver::params {
  $apps_dir = "/opt/apps"
  $app_user = $::is_vagrant ? {
    'true'  => 'vagrant',
    default => 'www-data',
  }
  $app_group = 'deploy'
  $nodejs_url = 'http://nodejs.org/dist/v0.6.19/node-v0.6.19.tar.gz'
  $python_ve_dir = '/opt/ve'
}
