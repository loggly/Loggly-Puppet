# == Class: loggly
#
# Base class for Loggly integration.  This module sets up the required
# infrastructure for Loggly integration to function, such as support
# directories and TLS certificates.
#
# Normally this class would not be called directly, but by one of the
# sub-modules that implements specific log sources such as loggly::rsyslog.
#
# === Parameters
#
# Defaults for these parameters are inherited from the loggly::params class.
#
# [*base_dir*]
#   Base directory to store Loggly support files in.
# [*enable_tls*]
#   Enables or disables TLS encryption for shipped log events.
# [*cert_path*]
#   Directory to store the Loggly TLS certs in.  Normally this would be relative
#   to $base_dir.
#
# === Authors
#
# Colin Moller <colin@unixarmy.com>
#

class loggly (
    $base_dir   = $loggly::params::base_dir,
    $enable_tls = $loggly::params::enable_tls,
    $cert_path  = $loggly::params::cert_path
) inherits loggly::params {

    # create directory for loggly support files
    file { $base_dir:
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
    }

    # create directory for TLS certificates
    file { $cert_path:
        ensure  => 'directory',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => File[$base_dir],
    }

    # store the Loggly TLS cert inside $cert_path
    file { "${cert_path}/loggly_full.crt":
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('loggly/loggly_full.crt.erb'),
        require => File[$cert_path],
    }
}

# vi:syntax=puppet:filetype=puppet:ts=4:et:
