class base::service {
  service { "rsyslog":
    ensure  => running,
  }
}