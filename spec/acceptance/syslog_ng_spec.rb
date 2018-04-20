require 'spec_helper_acceptance'

describe 'syslog_ng class' do
  # Using puppet_apply as a helper
  # Install syslog-ng as this module assumes it is installed outside of it
  it 'should work idempotently with no errors' do
    case fact('operatingsystem')
    when 'CentOS'
      pp = <<-EOS
      package { 'epel-release':
        ensure  => 'installed',
      }

      package { 'syslog-ng':
        ensure  => 'installed',
        require => Package['epel-release'],
      }

      class { 'loggly::syslog_ng':
        customer_token => '00000000-0000-0000-0000-000000000000',
        cert_path      => '/usr/local/loggly/certs',
        enable_tls     => true,
      }
      EOS
    else
      pp = <<-EOS
      package { 'syslog-ng':
        ensure  => 'installed',
      }

      class { 'loggly::syslog_ng':
        customer_token => '00000000-0000-0000-0000-000000000000',
        cert_path      => '/usr/local/loggly/certs',
        enable_tls     => true,
      }
      EOS
    end
    # Run it twice and test for idempotency
    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes  => true)
  end

  describe package('syslog-ng') do
    it { is_expected.to be_installed }
  end

  describe service('syslog-ng') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end

  describe file('/etc/syslog-ng/conf.d/22-loggly.conf') do
    it { is_expected.to be_file }
    it { is_expected.to be_owned_by 'root' }
    it { is_expected.to be_grouped_into 'root' }
    it { should contain 'LogglyFormat' }
  end
end
