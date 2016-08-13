# == Define: loggly::uninstall
#
# Removes loggly in its entirety.
# If any custom logs were specified, they must be specified here for removal.
#
# === Parameters
#
# [*logname*]
#   The label of the log file to remove configuration from if it was previously specified.
#
# [*filepath*]
#   The fully qualified path to the file to remove configuration from.
#
# === Variables
#
# [*_t*]
#   An internal temp variable used for string parsing.
#
# [*_logname*]
#   An internal temp variable used for string parsing.
#
# === Examples
#
#  loggly::uninstall { 'remove': }
#
#  loggly::uninstall { '/phil/collins': }
#
#  loggly::uninstall { '/phil/collins':
#    logname => 'in_the_air_tonight',
#  }
#
# === Authors
#
# Drew Rothstein <drew@drewrothstein.com>
#
define loggly::uninstall (
  $logname  = undef,
  $filepath = $title,
) {
  include loggly::params

  file { $::loggly::params::base_dir:
    ensure  => absent,
    recurse => true,
    purge   => true,
    force   => true,
  }

  file { '/etc/rsyslog.d/22-loggly.conf':
    ensure => absent,
    notify => Exec['restart_rsyslogd'],
  }

  file { '/etc/syslog-ng/conf.d/22-loggly.conf':
    ensure => absent,
    notify => Exec['restart_syslog_ng'],
  }

  if is_absolute_path($filepath) {
    $_t = split($filepath, '/')
    $_logname = pick($logname, $_t[-1])

    validate_string($_logname)

    file { "/etc/rsyslog.d/${_logname}.conf":
      ensure => absent,
      notify => Exec['restart_rsyslogd'],
    }
  }

  exec { 'restart_rsyslogd':
    command     => 'service rsyslog restart',
    path        => [ '/usr/sbin', '/sbin', '/usr/bin/', '/bin', ],
    refreshonly => true,
  }

  exec { 'restart_syslog_ng':
    command     => 'service syslog-ng restart',
    path        => [ '/usr/sbin', '/sbin', '/usr/bin/', '/bin', ],
    refreshonly => true,
  }
}

# vim: syntax=puppet ft=puppet ts=2 sw=2 nowrap et
