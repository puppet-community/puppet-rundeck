require 'spec_helper'

describe 'rundeck::config::plugin', :type => :define do
  context 'supported operating systems' do
    %w(Debian RedHat).each do |osfamily|
      describe "rundeck::config::plugin definition without any parameters on #{osfamily}" do
        name = 'rundeck-hipchat-plugin-1.0.0.jar'
        source = 'http://search.maven.org/remotecontent?filepath=com/hbakkum/rundeck/plugins/rundeck-hipchat-plugin/1.0.0/rundeck-hipchat-plugin-1.0.0.jar'
        plugin_dir = '/var/lib/rundeck/libext'

        let(:title) { name }
        let(:params) do
          {
            'source' => source,
            'plugin_config' => {
              'framework.plugin.StreamingLogWriter.LogstashPlugin.port' => '9700'
            }
          }
        end
        let(:facts) do
          {
            :osfamily        => 'Debian',
            :serialnumber    => 0,
            :rundeck_version => '',
            :puppetversion   => Puppet.version
          }
        end

        it do
          should contain_archive("download plugin #{name}").with(
            'source' => 'http://search.maven.org/remotecontent?filepath=com/hbakkum/rundeck/plugins/rundeck-hipchat-plugin/1.0.0/rundeck-hipchat-plugin-1.0.0.jar'
          )
        end

        it do
          should contain_file("#{plugin_dir}/#{name}").with(
            'mode'   => '0644',
            'owner'  => 'rundeck',
            'group'  => 'rundeck'
          )
        end
      
        it 'should generate valid content for framework.properties' do
          content = catalogue.resource('concat::fragment', "framework.properties+20_#{name}")[:content]
          expect(content).to match(/^framework\.plugin\.StreamingLogWriter\.LogstashPlugin\.port\ *=\ *9700$/)
        end
      end

      describe "rundeck::config::plugin definition with ensure set to absent on #{osfamily}" do
        name = 'rundeck-hipchat-plugin-1.0.0.jar'
        source = 'http://search.maven.org/remotecontent?filepath=com/hbakkum/rundeck/plugins/rundeck-hipchat-plugin/1.0.0/rundeck-hipchat-plugin-1.0.0.jar'
        plugin_dir = '/var/lib/rundeck/libext'

        let(:title) { name }
        let(:params) do
          {
            'source' => source,
            'ensure' => 'absent'
          }
        end

        let(:facts) do
          {
            :osfamily        => 'Debian',
            :serialnumber    => 0,
            :rundeck_version => '',
            :puppetversion   => Puppet.version
          }
        end

        it do
          should contain_file("#{plugin_dir}/#{name}").with(
            'ensure' => 'absent'
          )
        end
      end
    end
  end
end
