require 'spec_helper'

describe 'loggly::syslog_ng' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "loggly::syslog_ng class without any parameters" do
          let(:params) {{ }}

          it { should_not compile }
        end

        context "loggly::syslog_ng class with invalid customer_token" do
          let(:params) {{
            :customer_token => [ 'thing1', 'thing2' ],
          }}

          it { should_not compile }
        end

        context "loggly::syslog_ng class with invalid cert_path" do
          let(:params) {{
            :customer_token => '0000-0000-0000',
            :cert_path      => 'relative/path',
          }}
          it { should_not compile }
        end

        context "loggly::syslog_ng class with invalid enable_tls" do
          let(:params) {{
            :customer_token => '0000-0000-0000',
            :enable_tls     => 'yes',
          }}
          it { should_not compile }
        end

        context "loggly::ssylog_ng class with customer_token" do
          let(:params) {{
            :customer_token => '0000-0000-0000',
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('loggly::syslog_ng') }

         
          it { 
            is_expected.to contain_file('/etc/syslog-ng/conf.d').with(
              'ensure' => 'directory',
              'owner'  => 'root',
              'group'  => 'root',
              'mode'   => '0755'
            )
          }

          case os
          when /redhat.*/, /centos.*/
            context "add snippet_dir" do
              it { 
                is_expected.to contain_file_line('snippet_dir').with(
                  'ensure' => 'present',
                  'path'   => '/etc/syslog-ng/syslog-ng.conf',
                )
              }
            end

            context "default disable tls" do
              it { 
                is_expected.to contain_file('/etc/syslog-ng/conf.d/22-loggly.conf').with(
                  'owner'   => 'root',
                  'group'   => 'root',
                  'mode'    => '0644',
                  'content' => /# Non-encrypted log sink/,
                  'require' => 'File[/etc/syslog-ng/conf.d]',
                  'notify'  => 'Exec[restart_syslog_ng]',
                )
              }
            end
          else
            context "should not need snippet_dir" do
              it { should_not contain_file_line('snippet_dir') }
            end

            context "default enable tls" do
              it { 
                is_expected.to contain_file('/etc/syslog-ng/conf.d/22-loggly.conf').with(
                  'owner'   => 'root',
                  'group'   => 'root',
                  'mode'    => '0644',
                  'content' => /# TLS-enabled log sink/,
                  'require' => 'File[/etc/syslog-ng/conf.d]',
                  'notify'  => 'Exec[restart_syslog_ng]',
                )
              }
            end
          end

          it {
            is_expected.to contain_exec('restart_syslog_ng').with(
              'command'     => 'service syslog-ng restart',
              'refreshonly' => true,
            )
          }

        end
      end
    end
  end
end
