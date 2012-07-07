class solr::service {
  service { 'tomcat6':
    ensure  => running,
  }
}