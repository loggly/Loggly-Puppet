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
    # base directory for loggly support files
    $base_dir = '/usr/local/loggly'

    # directory that shared TLS certificates will be stored in
    $cert_path = "${base_dir}/certs"

    # TLS support is enabled by default to prevent sniffing of logs
    $enable_tls = true
}

# vi:syntax=puppet:filetype=puppet:ts=4:et:
