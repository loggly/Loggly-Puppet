# == Define: loggly::utils::line
#
# Ensures a specific line exists in a file, adds it if not already present.
#
# === Parameters
#
# Document parameters here
#
# [*file*]
#   namevar of a core resource type.
#
# [*line*]
#   slash."
#
# [*ensure*]
#   Foo
#
# === Examples
#
# Examples on how to use this type:
#
#   loggly::utils::line { 'line_in_motd':
#       file   => '/etc/motd',
#       line   => 'hello, world!',
#       ensure => 'present',
#   }
#
# === Authors
#
# Colin Moller <colin@unixarmy.com>
#

define loggly::utils::line($file, $line, $ensure = 'present') {
    case $ensure {
        default : { err ( "unknown ensure value ${ensure}" ) }
        present: {
            exec { "/bin/echo '${line}' >> '${file}'":
                unless => "/bin/grep -qFx '${line}' '${file}'"
            }
        }
        absent: {
            exec { "/usr/bin/perl -ni -e 'print unless /^\\Q${line}\\E\$/' '${file}'":
                onlyif => "/bin/grep -qFx '${line}' '${file}'"
            }
        }
    }
}

# vi:syntax=puppet:filetype=puppet:ts=4:et:
