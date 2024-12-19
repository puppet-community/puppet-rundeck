# frozen_string_literal: true

require 'spec_helper'

describe 'rundeck::cli' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      context 'with default parameters' do
        it { is_expected.to compile }

        it { is_expected.to contain_package('jq').with(ensure: 'installed') }

        case facts[:os]['family']
        when 'RedHat'
          it do
            is_expected.to contain_yumrepo('rundeck').with(
              baseurl: 'https://packages.rundeck.com/pagerduty/rundeck/rpm_any/rpm_any/$basearch',
              repo_gpgcheck: 1,
              gpgcheck: 0,
              enabled: 1,
              gpgkey: 'https://packages.rundeck.com/pagerduty/rundeck/gpgkey'
            ).that_comes_before('Package[rundeck-cli]')
          end
        when 'Debian'
          it do
            is_expected.to contain_apt__source('rundeck').with(
              location: 'https://packages.rundeck.com/pagerduty/rundeck/any',
              release: 'any',
              repos: 'main',
              key: {
                'name' => 'rundeck.asc',
                'content' => %r{^-----BEGIN PGP PUBLIC KEY BLOCK-----},
              }
            ).that_comes_before('Package[rundeck-cli]')
          end

          it { is_expected.to contain_class('apt::update').that_comes_before('Package[rundeck-cli]') }
          it { is_expected.to contain_package('rundeck-cli').with(ensure: 'installed') }
          it { is_expected.to contain_file('/usr/local/bin/rd_project_diff.sh').with(ensure: 'file', mode: '0755') }
          it { is_expected.to contain_file('/usr/local/bin/rd_job_diff.sh').with(ensure: 'file', mode: '0755') }
          it { is_expected.to contain_file('/usr/local/bin/rd_scm_diff.sh').with(ensure: 'file', mode: '0755') }
        end

        it do
          is_expected.to contain_exec('Check rundeck cli connection').with(
            command: 'rd system info',
            path: ['/bin', '/usr/bin', '/usr/local/bin'],
            environment: [
              'RD_FORMAT=json',
              'RD_URL=http://localhost:4440',
              'RD_BYPASS_URL=http://localhost:4440',
              'RD_USER=admin',
              'RD_PASSWORD=admin',
            ],
            tries: 60,
            try_sleep: 5,
            unless: 'rd system info &> /dev/null'
          ).that_requires('Package[rundeck-cli]')
        end
      end

      context 'with different urls and token auth' do
        let(:params) do
          {
            url: 'http://rundeck01.example.com',
            bypass_url: 'http://rundeck.example.com',
            token: 'very_secure'
          }
        end

        it do
          is_expected.to contain_exec('Check rundeck cli connection').with(
            environment: [
              'RD_FORMAT=json',
              'RD_URL=http://rundeck01.example.com',
              'RD_BYPASS_URL=http://rundeck.example.com',
              'RD_TOKEN=very_secure',
            ]
          )
        end
      end

      context 'with projects config' do
        let(:params) do
          {
            projects: {
              'MyProject' => {
                'update_method' => 'set',
                'config' => {
                  'project.description' => 'This is My rundeck project',
                  'project.disable.executions' => 'false',
                },
                'jobs' => {
                  'MyJob1' => {
                    'path'   => '/etc/myjob1',
                    'format' => 'yaml',
                  },
                  'MyJob2' => {
                    'path'   => '/etc/myjob2',
                    'format' => 'xml',
                  },
                },
              },
              'TestProject' => {
                'config' => {
                  'project.description' => 'This is a rundeck test project',
                  'project.disable.schedule' => 'false',
                },
                'jobs' => {
                  'TestJob1' => {
                    'path'   => '/etc/testjob1',
                    'format' => 'yaml',
                  },
                },
              },
            },
          }
        end

        it do
          is_expected.to contain_rundeck__config__project('MyProject').with(
            update_method: 'set',
            config: {
              'project.description' => 'This is My rundeck project',
              'project.disable.executions' => 'false',
            },
            jobs: {
              'MyJob1' => {
                'path'   => '/etc/myjob1',
                'format' => 'yaml',
              },
              'MyJob2' => {
                'path'   => '/etc/myjob2',
                'format' => 'xml',
              },
            }
          )
        end

        it { is_expected.to contain_exec('(MyProject) Create/update job: MyJob1') }
        it { is_expected.to contain_exec('(MyProject) Create/update job: MyJob2') }

        it do
          is_expected.to contain_rundeck__config__project('TestProject').with(
            config: {
              'project.description' => 'This is a rundeck test project',
              'project.disable.schedule' => 'false',
            },
            jobs: {
              'TestJob1' => {
                'path'   => '/etc/testjob1',
                'format' => 'yaml',
              }
            }
          )
        end

        it { is_expected.to contain_exec('(TestProject) Create/update job: TestJob1') }
      end
    end
  end
end
