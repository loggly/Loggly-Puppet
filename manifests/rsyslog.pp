# == Class: loggly::rsyslog
#
# Configures the rsyslog daemon to submit syslog events to Loggly.
#
# === Parameters
#
# [*customer_token*]
#   Customer Token that will be used to identify which Loggly account events
#   will be submitted to.
#
#   More information on how to generate and obtain the Customer Token can be
#   found in the Loggly documentation at:
#     http://www.loggly.com/docs/customer-token-authentication-token/
#
# === Variables
#
# This module uses configuration from the base Loggly class to set
# the certificate path and TLS status.
#
# [*cert_dir*]
#   The directory to find the Loggly TLS certs in, as set by the base loggly
#   class.
#
# [*enable_tls*]
#   Enables or disables TLS encryption for shipped events.
#
# === Examples
#
#  class { 'loggly::rsyslog':
#    customer_token => '00000000-0000-0000-0000-000000000000',
#  }
#
# === Authors
#
# Colin Moller <colin@unixarmy.com>
#
class loggly::rsyslog (
    $customer_token
) inherits loggly {

    # Bring the TLS and certificate directory configuration into the current
    # Puppet scope so that templates have access to it
    $enable_tls = $loggly::enable_tls
    $cert_path = $loggly::cert_path

    # Emit a configuration snippet that submits events to Loggly by default
    file { '/etc/rsyslog.d/22-loggly.conf':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('loggly/rsyslog/22-loggly.conf.erb'),
        notify  => Exec['restart_rsyslogd'],
    }

    # TLS configuration requires an extra package to be installed
    if $enable_tls == true {
        package { 'rsyslog-gnutls':
            ensure => 'installed',
            notify => Exec['restart_rsyslogd'],
        }

        # Add a dependency on the rsyslog-gnutls package to the configuration
        # snippet so that it will be installed before we generate any config
        File['/etc/rsyslog.d/22-loggly.conf'] -> Package['rsyslog-gnutls']
    }

    # Call an exec to restart the syslog service instead of using a puppet
    # managed service to avoid external dependencies or conflicts with modules
    # that may already manage the syslog daemon.
    #
    # Note that this will only be called on configuration changes due to the
    # 'refreshonly' parameter.
    exec { 'restart_rsyslogd':
        command     => 'service rsyslog restart',
        path        => [ '/usr/sbin', '/sbin', '/usr/bin/', '/bin', ],
        refreshonly => true,
    }

    define logfile($logname,$filepath,$severity='info') {
        file { "/etc/rsyslog.d/$logname.conf":
            content => template("loggly/log.conf.erb"),
            notify => Exec["restart_rsyslogd"],
        }
    }

}

# vi:syntax=puppet:filetype=puppet:ts=4:et:
