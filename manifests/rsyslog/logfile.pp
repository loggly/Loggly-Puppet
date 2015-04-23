# == Define: loggly::rsyslog::logfile
#
# Adds the monitoring of a file.
#
# === Parameters
#
# [*logname*]
#   The label to be applied to this log file.
#   If it is not present it will default to the short name of the file
#
# [*filepath*]
#   The fully qualified path to the file to monitor.
#
# [*severity*]
#   Standard syslog severity levels.  Default: info
#
# === Variables
#
# [*valid_levels*]
#   A list of valid severity levels.
#
# [*_t*]
#   An internal temp variable used for string parsing
#
# === Examples
#
#  loggly::rsyslog::logfile { '/opt/customapp/log':
#    logname => 'MY_App',
#  }
#
# === Authors
#
# Colin Moller <colin@unixarmy.com>
#
define loggly::rsyslog::logfile (
  $logname  = undef,
  $filepath = $title,
  $severity = 'info'
) {

  $valid_levels = [
    'emerg', 'alert', 'crit', 'error',
    'warning', 'notice', 'info', 'debug',
  ]

  validate_absolute_path($filepath)
  validate_re($severity, $valid_levels, "severity value of ${severity} is not valid")

  if ! $logname {
    $_t = split($filepath, '/')
    $logname = $_t[-1]
  }

  validate_string($logname)

  # This template uses $logname and $filepath
  file { "/etc/rsyslog.d/${logname}.conf":
    content => template("${module_name}/log.conf.erb"),
    notify  => Exec['restart_rsyslogd'],
  }
}

# vi:syntax=puppet:filetype=puppet:ts=4:et:
