require 'spec_helper_acceptance'

describe 'rsyslog class' do
  # Using puppet_apply as a helper
  it 'should work idempotently with no errors' do
    pp = <<-EOS
    class { 'loggly::rsyslog':
      customer_token => '00000000-0000-0000-0000-000000000000',
      cert_path      => '/usr/local/loggly/certs',
      enable_tls     => true,
    }
    EOS

    # Run it twice and test for idempotency
    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes  => true)
  end

  describe package('rsyslog-gnutls') do
    it { is_expected.to be_installed }
  end

  describe service('rsyslog') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end

  describe file('/etc/rsyslog.d/22-loggly.conf') do
    it { is_expected.to be_file }
    it { is_expected.to be_owned_by 'root' }
    it { is_expected.to be_grouped_into 'root' }
    it { should contain 'LogglyFormat' }
  end
end
