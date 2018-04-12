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
# [*customer_token*]
#   The unique token from the Loggly interface to identify your account
#
# [*cert_path*]
#   The path in which to find the Loggly TLS certs, as set by the base loggly
#   class.
#
# [*enable_tls*]
#   Enables or disables TLS encryption for shipped events.
#
# [*action_queue_file_name*]
#   The $ActionQueueFileName setting
#
# [*action_queue_max_disk_space*]
#   The $ActionQueueMaxDiskSpace setting
#
# [*action_queue_save_on_shutdown*]
#   The $ActionQueueSaveOnShutdown setting
#
# [*action_queue_type*]
#   The $ActionQueueType setting
#
# [*action_resume_retry_count*]
#   The $ActionQueueRetryCount setting
#
# [*appname_string*]
#   A custom application name property string.  The default is "app-name", but
#   could be "programname" or "syslogtag" or any other rsyslog property,
#   including modifiers like regexp.
#
# === Examples
#
# = Basic setup
#
#  class { 'loggly::rsyslog':
#    customer_token => '00000000-0000-0000-0000-000000000000',
#  }
#
# = Custom app-name setup (for app names with slashes in them)
#
#  class { 'loggly::rsyslog':
#    customer_token => '00000000-0000-0000-0000-000000000000',
#    appname_string => 'syslogtag:R,ERE,1,DFLT:(.*)\\[--end'
#  }
#
# === Authors
#
# Colin Moller <colin@unixarmy.com>
#
class loggly::rsyslog (
  $customer_token                = undef,
  $cert_path                     = $loggly::_cert_path,
  $enable_tls                    = $loggly::enable_tls,
  $action_queue_file_name        = $loggly::params::rsyslog_action_queue_file_name,
  $action_queue_max_disk_space   = $loggly::params::rsyslog_action_queue_max_disk_space,
  $action_queue_save_on_shutdown = $loggly::params::rsyslog_action_queue_save_on_shutdown,
  $action_queue_type             = $loggly::params::rsyslog_action_queue_type,
  $action_resume_retry_count     = $loggly::params::rsyslog_action_resume_retry_count,
  $appname_string                = $loggly::params::rsyslog_appname_string
) inherits loggly {

  validate_string($customer_token)
  validate_absolute_path($cert_path)
  validate_bool($enable_tls)
  validate_string($appname_string)

  # Use different config format if rsyslog version > 5$ActionQueueFileName fwdLoggly # unique name prefix for spool files
  if (versioncmp($::syslog_version, '5') > 0) {
    $template_file = "loggly.conf.erb"
  } else {
    $template_file = "loggly_pre7.conf.erb"
  }

  # Emit a configuration snippet that submits events to Loggly by default
  file { '/etc/rsyslog.d/22-loggly.conf':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/rsyslog/${template_file}"),
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
    Class['loggly'] -> File['/etc/rsyslog.d/22-loggly.conf'] -> Package['rsyslog-gnutls']
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
    subscribe   => File["${loggly::_cert_path}/loggly_full.crt"]
  }
}

# vim: syntax=puppet ft=puppet ts=2 sw=2 nowrap et
