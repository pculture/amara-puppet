class config::roles::data {
  include rabbitmq
  include redis
  include solr
  class { 'config::config':
    require => [
      Class['rabbitmq'],
      Class['redis'],
      Class['solr'],
    ],
  }
}