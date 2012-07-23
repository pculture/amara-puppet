class config::config inherits config::params {
  $roles = $::system_roles ? {
    undef => [],
    default => $::system_roles,
  }
}
