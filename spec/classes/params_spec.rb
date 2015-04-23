require 'spec_helper'

describe 'loggly::params' do #, :type => :class do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        it { is_expected.to contain_class("loggly::params") }
      end
    end
  end

  context 'unsupported operating system' do
    describe 'loggly class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { is_expected.to contain_package('loggly') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
