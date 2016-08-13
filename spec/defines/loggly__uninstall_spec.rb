require 'spec_helper'

describe 'loggly::uninstall', :type => :define do
  let(:facts) do
    {
      :operatingsystem => 'RedHat'
    }
  end

  context 'should remove loggly configuration directory and files' do
    let :title do
      'remove_me'
    end

    it { is_expected.to contain_file(
      '/etc/rsyslog.d/22-loggly.conf').with_ensure(
      'absent').that_notifies('Exec[restart_rsyslogd]') }

    it { is_expected.to contain_file(
      '/etc/syslog-ng/conf.d/22-loggly.conf').with_ensure(
      'absent').that_notifies('Exec[restart_syslog_ng]') }
  end

  context 'should remove configuration for $title' do
    let :title do
      '/phil/collins'
    end

    it { is_expected.to contain_file(
      '/etc/rsyslog.d/collins.conf').with_ensure('absent') }
  end

  context 'should remove configuration for $logname' do
    let :title do
      '/phil/collins'
    end
    
    let(:params) {{
      :logname => 'in_the_air_tonight'
    }}

    it { is_expected.to contain_file(
      '/etc/rsyslog.d/in_the_air_tonight.conf').with_ensure('absent') }
  end

  context 'should remove configuration for $logname and notify' do
    let :title do
      '/phil/collins'
    end
    
    let(:params) {{
      :logname => 'in_the_air_tonight'
    }}

    it { is_expected.to contain_file(
      '/etc/rsyslog.d/in_the_air_tonight.conf').with_ensure(
      'absent').that_notifies('Exec[restart_rsyslogd]') }
  end
end
