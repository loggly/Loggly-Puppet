# == Class: loggly::syslog_ng
#
# Configures the syslog-ng daemon to submit syslog events to Loggly.
#
# Please note that this module will add configuration to the default
# configuration file for syslog-ng on Red Hat based distributions.
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
#   Enabled on all distros except CentOS and Red Hat Enterprise Linux as the
#   packages for those distros are not compiled with TLS support by default.
#
# === Examples
#
#  class { 'loggly::syslog_ng':
#    customer_token => '00000000-0000-0000-0000-000000000000',
#  }
#
# === Authors
#
# Colin Moller <colin@unixarmy.com>
#
class loggly::syslog_ng (
  $customer_token
) inherits loggly {

  # Bring the Loggly certificate directory configuration into the current
  # Puppet scope so templates have access to it
  $cert_dir     = $loggly::cert_dir

  # Ensure our configuration snippet directory exists before putting
  # configuration snippets there
  if !defined(File['/etc/syslog-ng/conf.d']){
    file { '/etc/syslog-ng/conf.d':
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
  }
  # Ensure we are using the correct source name on each distro
  $syslog_source = $::osfamily ? {
    'RedHat' => 's_sys',
    'Debian' => 's_src',
  }

  case $::operatingsystem {
    centos, redhat: {
      # On CentOS/Red Hat, the default syslog-ng configuration does not
      # include a configuration snippet directory, so we ensure it is 
      # present
      file_line { 'snippet_dir':
        ensure => present,
        path   => '/etc/syslog-ng/syslog-ng.conf',
        line   => '@include "/etc/syslog-ng/conf.d/"',
        before => File['/etc/syslog-ng/conf.d/22-loggly.conf'],
      }

      # Packages available from the EPEL repo for syslog-ng on
      # CentOS/Red Hat are not compiled with TLS support by default
      $enable_tls   = false
    }

    # Respect the default set in the loggly class on other distros
    default: {
      $enable_tls   = $loggly::enable_tls
    }
  }

  # Emit a configuration snippet that submits events to Loggly by default
  # This template uses $enable_tls, $customer_token, and $cert_path 
  file { '/etc/syslog-ng/conf.d/22-loggly.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/syslog-ng/22-loggly.conf.erb"),
    require => File['/etc/syslog-ng/conf.d'],
    notify  => Exec['restart_syslog_ng'],
  }

  # Call an exec to restart the syslog service instead of using a puppet
  # managed service to avoid external dependencies or conflicts with 
  # modules that may already manage the syslog daemon.
  #
  # Note that this will only be called on configuration changes due to the
  # 'refreshonly' parameter.
  exec { 'restart_syslog_ng':
    command     => 'service syslog-ng restart',
    path        => [ '/usr/sbin', '/sbin', '/usr/bin/', '/bin', ],
    refreshonly => true,
  }
}

# vim: syntax=puppet ft=puppet ts=2 sw=2 nowrap et
