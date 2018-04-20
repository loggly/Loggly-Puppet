require 'spec_helper_acceptance'

describe 'loggly class' do
  # Using puppet_apply as a helper
  it 'should work idempotently with no errors' do
    pp = <<-EOS
    class { 'loggly':
      base_dir   => '/usr/local/loggly',
      enable_tls => true,
    }
    EOS

    # Run it twice and test for idempotency
    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes  => true)
  end

  describe file('/usr/local/loggly') do
    it { is_expected.to be_directory }
    it { is_expected.to be_owned_by 'root' }
    it { is_expected.to be_grouped_into 'root' }
  end

  describe file('/usr/local/loggly/certs') do
    it { is_expected.to be_directory }
    it { is_expected.to be_owned_by 'root' }
    it { is_expected.to be_grouped_into 'root' }
  end

  describe file('/usr/local/loggly/certs/loggly_full.crt') do
    it { is_expected.to be_file }
    it { is_expected.to be_owned_by 'root' }
    it { is_expected.to be_grouped_into 'root' }
    it { should contain 'BEGIN CERTIFICATE' }
    it { should contain 'END CERTIFICATE' }
  end
end
