# == Class: loggly::params
#
# Provides defaults for the Loggly base class.
#
# Normally this class would not be called on its own, but by the loggly class.
#
# === Authors
#
# Colin Moller <colin@unixarmy.com>
#

class loggly::params {
  case $operatingsystem {
    'RedHat', 'Ubuntu', 'Fedora', 'CentOS', 'Debian': {
      # base directory for loggly support files
      $base_dir = '/usr/local/loggly'

      # TLS support is enabled by default to prevent sniffing of logs
      $enable_tls = true
    }

    default: {
      fail("$operatingsystem not supported")
    }
  }

  $tags = []
}

# vim: syntax=puppet ft=puppet ts=2 sw=2 nowrap et
