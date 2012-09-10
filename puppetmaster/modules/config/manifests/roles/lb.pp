class config::roles::lb {
  # base modules to include
  if ! defined(Class['nginx']) { class { 'nginx': } }
}
