# rubocop:disable RSpec/MultipleExpectations

require 'spec_helper'

describe 'rundeck' do
  on_supported_os.each do |os, facts|
    context "on #{os} " do
      let :facts do
        facts
      end

      describe "rundeck class without any parameters on #{os}" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('rundeck::params') }
        it { is_expected.to contain_class('rundeck::install').that_comes_before('Class[rundeck::config]') }
        it { is_expected.to contain_class('rundeck::config') }
        it { is_expected.to contain_class('rundeck::service').that_comes_before('Class[rundeck]') }
        it { is_expected.to contain_class('rundeck').that_requires('Class[rundeck::service]') }
      end

      context 'non-platform-specific config parameters' do
        # auth_config cannot be passed as a parameter to rundeck::config :-(
        # so we have to test it here
        describe 'setting auth_config ldap roleUsernameMemberAttribute' do
          let(:params) do
            {
              auth_types: ['ldap'],
              auth_config: {
                'ldap' => {
                  'role_username_member_attribute' => 'memberUid'
                }
              }
            }
          end

          it { is_expected.to contain_file('/etc/rundeck/jaas-auth.conf') }
          it 'generates valid content for jaas-auth.conf' do
            content = catalogue.resource('file', '/etc/rundeck/jaas-auth.conf')[:content]
            expect(content).to include('roleUsernameMemberAttribute="memberUid"')
            expect(content).not_to include('roleMemberAttribute')
          end
        end

        describe 'setting auth_config ldap url' do
          let(:params) do
            {
              auth_types: ['ldap'],
              auth_config: {
                'ldap'     => {
                  'url'    => 'ldaps://myrealldap.example.com',
                  'server' => 'fakeldap',
                  'port'   => '983'
                }
              }
            }
          end

          it { is_expected.to contain_file('/etc/rundeck/jaas-auth.conf') }
          it 'generates valid content for jaas-auth.conf' do
            content = catalogue.resource('file', '/etc/rundeck/jaas-auth.conf')[:content]
            expect(content).to include('providerUrl="ldaps://myrealldap.example.com"')
            expect(content).not_to include('providerUrl="ldap://fakeldap:983"')
          end
        end

        describe 'uuid setting' do
          context 'when serialnumber fact present' do
            let :facts do
              facts.merge(fqdn: 'rundeck.example.com',
                          serialnumber: '32142097')
            end

            it { is_expected.to contain_file('/etc/rundeck/framework.properties') }
            it 'uses serialnumber fact for \'rundeck.server.uuid\'' do
              content = catalogue.resource('file', '/etc/rundeck/framework.properties')[:content]
              expect(content).to include('rundeck.server.uuid = 32142097')
            end
          end

          context 'when serialnumber fact absent' do
            let :facts do
              facts.merge(fqdn: 'rundeck.example.com', # uuid is ac7c2cbd-14fa-5ba3-b3f2-d436e9b8a3b0
                          serialnumber: nil)
            end

            it { is_expected.to contain_file('/etc/rundeck/framework.properties') }
            it 'uses serialnumber fact for \'rundeck.server.uuid\'' do
              content = catalogue.resource('file', '/etc/rundeck/framework.properties')[:content]
              expect(content).to include('rundeck.server.uuid = ac7c2cbd-14fa-5ba3-b3f2-d436e9b8a3b0')
            end
          end

          context 'when serialnumber is \'0\'' do
            let :facts do
              facts.merge(fqdn: 'rundeck.example.com', # uuid is ac7c2cbd-14fa-5ba3-b3f2-d436e9b8a3b0
                          serialnumber: '0')
            end

            it { is_expected.to contain_file('/etc/rundeck/framework.properties') }
            it 'uses serialnumber fact for \'rundeck.server.uuid\'' do
              content = catalogue.resource('file', '/etc/rundeck/framework.properties')[:content]
              expect(content).to include('rundeck.server.uuid = ac7c2cbd-14fa-5ba3-b3f2-d436e9b8a3b0')
            end
          end
        end
      end
    end
  end
end
