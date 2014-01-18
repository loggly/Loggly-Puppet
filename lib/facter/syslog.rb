# determines what syslog implementation is installed, and what version
# If both syslog-ng and rsyslog are installed, this module assumes that
# syslog-ng should take precedence, since the distros that this module
# supports ship rsyslogd by default.  The user would have had to install
# syslog-ng explicitly.

Facter.add("syslog_daemon") do
    setcode do
        distid = Facter.value('osfamily')
        case distid
        when /RedHat/
            syslog_ng_installed = Facter::Util::Resolution.exec('/bin/rpm -q syslog-ng 2>/dev/null | /bin/grep -c ^syslog-ng')
            if syslog_ng_installed != "0"
                "syslog-ng"
                else
                    rsyslog_installed = Facter::Util::Resolution.exec('/bin/rpm -q rsyslog 2>/dev/null | /bin/grep -c ^rsyslog')
                    if rsyslog_installed != "0"
                        "rsyslogd"
                    else
                        nil
                    end
                end
        when
            /Debian/
            syslog_ng_installed = Facter::Util::Resolution.exec('/usr/bin/dpkg-query -W -f \'${status}\' syslog-ng 2>/dev/null | /bin/grep -c ^install')
            if syslog_ng_installed != "0"
                "syslog-ng"
            else
                rsyslog_installed = Facter::Util::Resolution.exec('/usr/bin/dpkg-query -W -f \'${status}\' rsyslog 2>/dev/null | /bin/grep -c ^install')
                if rsyslog_installed != "0"
                    "rsyslogd"
                else
                    nil
                end
            end
        else
            nil
        end
    end
end

Facter.add("syslog_version") do
    setcode do
        syslog_daemon = Facter.value('syslog_daemon')
        syslog_version = nil

        distid = Facter.value('osfamily')

        case syslog_daemon
        when "syslog-ng"
            Facter::Util::Resolution.exec("#{syslog_daemon} -V | head -n1 | awk '{ print $2 }'")
        when "rsyslogd"
            Facter::Util::Resolution.exec("#{syslog_daemon} -v | head -n1 | awk '{ print $2 }' | sed 's/,//'")
        else
           nil
        end
    end
end
