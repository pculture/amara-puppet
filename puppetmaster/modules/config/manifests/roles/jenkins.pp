class config::roles::jenkins inherits config::params {
  if ! defined(Class['::jenkins']) {
    class { '::jenkins':
      port => $config::params::jenkins_port,
    }
  }
  if ! defined(Class['::closure']) { class { 'closure': } }
  if ! defined(Class['::rabbitmq']) { class { 'rabbitmq': } }
  if ! defined(Class['::redis']) { class { 'redis': } }
  if ! defined(Class['::seleniumsupport']) { class { 'seleniumsupport': } }
  if ! defined(Class['::solr']) { class { 'solr': configure => true, manage_cores => false } }
  if ! defined(Class['::virtualenv']) { class { 'virtualenv': } }
}
