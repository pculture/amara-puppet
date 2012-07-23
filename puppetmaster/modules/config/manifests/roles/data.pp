class config::roles::data {
  if ! defined(Class['rabbitmq']) { include rabbitmq }
  if ! defined(Class['redis']) { include redis }
  if ! defined(Class['solr']) { include solr }
  if ! defined(Class['config::config']) { 
    class { 'config::config':
      require => [
        Class['rabbitmq'],
        Class['redis'],
        Class['solr'],
      ],
    }
  }
}