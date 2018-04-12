require 'spec_helper'

describe 'loggly::rsyslog' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "loggly::rsyslog class without any parameters" do
          let(:params) {{ }}

          it { should_not compile }
        end

        context "loggly::rsyslog class with invalid customer_token" do
          let(:params) {{
            :customer_token => [ 'thing1', 'thing2' ],
          }}
          it { should_not compile }
        end

        context "loggly::rsyslog class with invalid cert_path" do
          let(:params) {{
            :customer_token => '0000-0000-0000',
            :cert_path      => 'relative/path',
          }}
          it { should_not compile }
        end

        context "loggly::rsyslog class with invalid enable_tls" do
          let(:params) {{
            :customer_token => '0000-0000-0000',
            :enable_tls     => 'yes',
          }}
          it { should_not compile }
        end

        context "loggly::rsyslog class with customer_token" do
          let(:params) {{
            :customer_token => '0000-0000-0000',
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('loggly::rsyslog') }

          it {
            is_expected.to contain_exec('restart_rsyslogd').with(
              'command'     => 'service rsyslog restart',
              'refreshonly' => true,
            )
          }
        end

        context "loggly::rsyslog class with enable_tls" do
          context "true" do
            let(:params) {{
              :customer_token => '0000-0000-0000',
              :enable_tls     => true,
            }}

            it {
              is_expected.to contain_file('/etc/rsyslog.d/22-loggly.conf').with(
                'ensure'  => 'file',
                'owner'   => 'root',
                'group'   => 'root',
                'mode'    => '0644',
                'content' => /#RsyslogGnuTLS/,
              )
            }

            it { is_expected.to contain_package('rsyslog-gnutls').with_ensure('installed') }
          end

          context "false" do
            let(:params) {{
              :customer_token => '0000-0000-0000',
              :enable_tls     => false,
            }}

            it {
              is_expected.to contain_file('/etc/rsyslog.d/22-loggly.conf').with(
                'ensure'  => 'file',
                'owner'   => 'root',
                'group'   => 'root',
                'mode'    => '0644',
                'content' => /logs-01\.loggly\.com:514; LogglyFormat/,
              )
            }
          end
        end

        context "loggly::rsyslog class with action_queue_file_name" do
          let(:params) {{
            :customer_token => '0000-0000-0000',
            :action_queue_file_name => 'testFile1'
          }}

          it {
            is_expected.to contain_file('/etc/rsyslog.d/22-loggly.conf').with(
              'ensure'  => 'file',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'content' => /\$ActionQueueFileName testFile1/,
            )
          }
        end

        context "loggly::rsyslog class with action_queue_max_disk_space" do
          let(:params) {{
            :customer_token => '0000-0000-0000',
            :action_queue_max_disk_space => '10g'
          }}

          it {
            is_expected.to contain_file('/etc/rsyslog.d/22-loggly.conf').with(
              'ensure'  => 'file',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'content' => /\$ActionQueueMaxDiskSpace 10g/,
            )
          }
        end

        context "loggly::rsyslog class with action_queue_save_on_shutdown" do
          let(:params) {{
            :customer_token => '0000-0000-0000',
            :action_queue_save_on_shutdown => 'off'
          }}

          it {
            is_expected.to contain_file('/etc/rsyslog.d/22-loggly.conf').with(
              'ensure'  => 'file',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'content' => /\$ActionQueueSaveOnShutdown off/,
            )
          }
        end

        context "loggly::rsyslog class with action_queue_type" do
          let(:params) {{
            :customer_token => '0000-0000-0000',
            :action_queue_type => 'Foo'
          }}

          it {
            is_expected.to contain_file('/etc/rsyslog.d/22-loggly.conf').with(
              'ensure'  => 'file',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'content' => /\$ActionQueueType Foo/,
            )
          }
        end

        context "loggly::rsyslog class with action_resume_retry_count" do
          let(:params) {{
            :customer_token => '0000-0000-0000',
            :action_resume_retry_count => '0'
          }}

          it {
            is_expected.to contain_file('/etc/rsyslog.d/22-loggly.conf').with(
              'ensure'  => 'file',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'content' => /\$ActionResumeRetryCount 0/,
            )
          }
        end

        context "loggly::rsyslog class with default appname_string" do
          let(:params) {{
            :customer_token => '0000-0000-0000',
          }}

          it {
            is_expected.to contain_file('/etc/rsyslog.d/22-loggly.conf').with(
              'ensure'  => 'file',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'content' => /app\-name/,
            )
          }
        end

        context "loggly::rsyslog class with custom appname_string" do
          let(:params) {{
            :customer_token => '0000-0000-0000',
            :appname_string => 'programname'
          }}

          it {
            is_expected.to contain_file('/etc/rsyslog.d/22-loggly.conf').with(
              'ensure'  => 'file',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'content' => /programname/,
            )
          }
        end

      end
    end
  end
end
