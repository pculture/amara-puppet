class config::package {
  if ! defined(Package["openjdk-6-jre"]) { package { "openjdk-6-jre": ensure => installed, } }
}
