class solr::params {
  $jvm_mem = $::is_vagrant ? {
    'true'   => 128,
    default => 2048,
  }
  $tomcat_user = 'tomcat6'
}
