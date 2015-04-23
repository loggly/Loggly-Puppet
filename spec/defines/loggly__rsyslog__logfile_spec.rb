require 'spec_helper'

describe 'loggly::rsyslog::logfile', :type => :define do
  context 'should require absolute path for $filepath' do
    let :title do
      'relative/path.log'
    end

    it { should_not compile } 

  end

  context 'should reject invalid $severity' do
    let :title do
      '/tmp/foo_log'
    end
    
    let(:params) {{
      :sevrity => 'invalid'
    }}

    it { should_not compile } 
  end

  context 'should create a config file' do
    let :title do
      '/tmp/foo_log'
    end

    it { is_expected.to contain_loggly__rsyslog__logfile('/tmp/foo_log') }

    describe 'with no parameters' do
      it { 
        is_expected.to contain_file('/etc/rsyslog.d/foo_log.conf').with(
          'content' => /InputFileTag foo_log:/,
        )
      }
    end

    describe 'with custom tag' do
      let(:params) {{
        :logname => 'the_real_foo',
      }}

      it {
        is_expected.to contain_file('/etc/rsyslog.d/the_real_foo.conf').with(
          'content' => /InputFileTag the_real_foo:/,
        )
      }
    end
  end
end
