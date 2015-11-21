# Author::    Liam Bennett (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class rundeck::params
#
# This class is meant to be called from `rundeck`
# It sets variables according to platform
#
class rundeck::params {

  case $::osfamily {
    'Debian': {
      $package_name = 'rundeck'
      $package_ensure = '2.5.1-1-GA'
      $service_name = 'rundeckd'
      $manage_yum_repo = false
    }
    'RedHat', 'Amazon': {
      $package_name = 'rundeck'
      $package_ensure = 'installed'
      $service_name = 'rundeckd'
      $manage_yum_repo = true
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

  $service_manage = false
  $service_config = ''
  $service_script = ''

  $rdeck_base = '/var/lib/rundeck'
  $rdeck_home = '/var/lib/rundeck'
  $service_logs_dir = '/var/log/rundeck'

  $framework_config = {
    'framework.server.name'     => $::fqdn,
    'framework.server.hostname' => $::fqdn,
    'framework.server.port'     => '4440',
    'framework.server.url'      => "http://${::fqdn}:4440",
    'framework.server.username' => 'admin',
    'framework.server.password' => 'admin',
    'rdeck.base'                => '/var/lib/rundeck',
    'framework.projects.dir'    => '/var/lib/rundeck/projects',
    'framework.etc.dir'         => '/etc/rundeck',
    'framework.var.dir'         => '/var/lib/rundeck/var',
    'framework.tmp.dir'         => '/var/lib/rundeck/var/tmp',
    'framework.logs.dir'        => '/var/lib/rundeck/logs',
    'framework.libext.dir'      => '/var/lib/rundeck/libext',
    'framework.ssh.keypath'     => '/var/lib/rundeck/.ssh/id_rsa',
    'framework.ssh.user'        => 'rundeck',
    'framework.ssh.timeout'     => '0',
    'rundeck.server.uuid'       => $::serialnumber,
  }

  $auth_types = ['file']
  $auth_users = {}
  $auth_template = 'rundeck/jaas-auth.conf.erb'

  $acl_template = 'rundeck/aclpolicy.erb'
  $api_template = 'rundeck/aclpolicy.erb'

  $acl_policies = [
    {
      'description' => 'Admin, all access',
      'context' => {
        'project' => '.*',
      },
      'for' => {
        'resource' => [
          {'allow' => '*'},
        ],
        'adhoc' => [
          {'allow' => '*'},
        ],
        'job' => [
          {'allow' => '*'},
        ],
        'node' => [
          {'allow' => '*'},
        ],
      },
      'by' => [{
        'group' => ['admin']
      }]
    },
    {
      'description' => 'Admin, all access',
      'context' => {
        'application' => 'rundeck',
      },
      'for' => {
        'resource' => [
          {'allow' => '*'},
        ],
        'project' => [
          {'allow' => '*'},
        ],
      },
      'by' => [{
        'group' => ['admin']
      }]
    }
  ]

  $api_policies = [
    {
      'description' => 'API project level access control',
      'context' => {
        'project' => '.*',
      },
      'for' => {
        'resource' => [
          { 'equals' => {'kind' => 'job'}, 'allow' => ['create','delete'] },
          { 'equals' => {'kind' => 'node'}, 'allow' => ['read','create','update','refresh'] },
          { 'equals' => {'kind' => 'event'}, 'allow' => ['read','create'] }
        ],
        'adhoc' => [
          {'allow' => ['read','run','kill']}
        ],
        'node' => [
          {'allow' => ['read','run']}
        ],
      },
      'by' => [{
        'group' => ['api_token_group']
      }]
    },
    {
      'description' => 'API Application level access control',
      'context' => {
        'application' => 'rundeck',
      },
      'for' => {
        'resource' => [
          { 'equals' => {'kind' => 'system'}, 'allow' => ['read'] }
        ],
        'project' => [
          { 'match' => {'name' => '.*'}, 'allow' => ['read'] }
        ],
        'storage' => [
          { 'match' => {'path' => '(keys|keys/.*)'}, 'allow' => '*' },
        ],
      },
      'by' => [{
        'group' => ['api_token_group']
      }]
    }
  ]

  $auth_config = {
    'file' => {
      'admin_user'     => $framework_config['framework.server.username'],
      'admin_password' => $framework_config['framework.server.password'],
      'auth_users'     => {},
      'file'           => '/etc/rundeck/realm.properties',
    },
    'pam' => {
      'service'            => 'sshd',
      'supplemental_roles' => ['user'],
      'store_pass'         => true,
      'clear_pass'         => undef,
      'try_first_pass'     => undef,
      'use_first_pass'     => undef,
      'use_unix_groups'    => undef,
    },
    'ldap' => {
      'server'                  => undef,
      'port'                    => '389',
      'force_binding'           => false,
      'force_binding_use_root'  => false,
      'bind_dn'                 => undef,
      'bind_password'           => undef,
      'user_base_dn'            => undef,
      'user_rdn_attribute'      => 'uid',
      'user_id_attribute'       => 'uid',
      'user_password_attribute' => 'userPassword',
      'user_object_class'       => 'user',
      'role_base_dn'            => undef,
      'role_name_attribute'     => 'cn',
      'role_member_attribute'   => 'memberUid',
      'role_object_class'       => 'group',
      'nested_groups'           => true,
    },
    'active_directory' => {
      'server'                  => undef,
      'port'                    => '389',
      'force_binding'           => true,
      'force_binding_use_root'  => true,
      'bind_dn'                 => undef,
      'bind_password'           => undef,
      'user_base_dn'            => undef,
      'user_rdn_attribute'      => 'sAMAccountName',
      'user_id_attribute'       => 'sAMAccountName',
      'user_password_attribute' => 'unicodePwd',
      'user_object_class'       => 'user',
      'role_base_dn'            => undef,
      'role_name_attribute'     => 'cn',
      'role_member_attribute'   => 'member',
      'role_object_class'       => 'group',
      'supplemental_roles'      => 'user',
      'nested_groups'           => true,
    },
  }

  $realm_template = 'rundeck/realm.properties.erb'

  $mail_config = {}

  $security_config = {
    'useHMacRequestTokens' => true,
    'apiCookieAccess'      => true,
  }

  $projects = {}
  $projects_default_org = ''
  $projects_default_desc = ''

  $file_copier_provider = 'jsch-scp'
  $node_executor_provider = 'jsch-ssh'

  $url_cache = true
  $url_timeout = '30'

  $resource_format = 'resourcexml'
  $include_server_node = false
  $default_source_type = 'file'
  $default_resource_dir = '/'

  $script_args_quoted = true
  $script_interpreter = '/bin/bash'

  $user = 'rundeck'
  $group = 'rundeck'

  $loglevel = 'INFO'
  $rss_enabled = false

  $clustermode_enabled = false

  $grails_server_url = "http://${::fqdn}:4440"

  $database_config = {
    'type'            => 'h2',
    'dbCreate'        => 'update',
    'url'             => 'jdbc:h2:file:/var/lib/rundeck/data/rundeckdb;MVCC=true',
    'driverClassName' => '',
    'username'        => '',
    'password'        => '',
    'dialect'         => '',
  }

  $log4j_config = {
    '/etc/rundeck/log4j.properties' => {
      loggers                       => {
        'log4j.rootlogger'            => {
          level                     => 'warn',
        },
        'log4j.com.dtolabs.rundeck.core' => {
          level                          => 'INFO',
        },
        'com.dtolabs.rundeck.core.authorization' => {
          level                                               => 'INFO',
          additivity                                          => false,
        },
        'com.dtolabs.rundeck.remoteservice.http.options' => {
          level                                                       => 'INFO',
          additivity                                                  => false,
        },
        'com.dtolabs.rundeck.data.jobs.changes' => {
          level                                              => 'INFO',
          additivity                                         => false,
        },
        'org.rundeck.api.requests' => {
          level                                 => 'INFO',
          additivity                            => false,
        },
        'org.rundeck.web.requests' => {
          level                                 => 'INFO',
          additivity                            => false,
        },
        'org.codehaus.groovy.grails' => {
          level                                   => 'warn',
          additivity                              => false,
        },
        'org.codehaus.groovy.grails.commons.spring' => {
          level                                                  => 'warn',
          additivity                                             => false,
        },
        'org.codehaus.groovy.grails.beans.factory' => {
          level                                                 => 'warn',
          additivity                                            => false,
        },
        'grails' => {
          level               => 'info',
          additivity          => false,
        },
      },
      appenders  => {
        'stdout' => {
          type   => 'console',
          layout => '%-5p %c{1}: %m%n',
        },
        'cmd-logger' => {
          type       => 'rollingfile',
          filename       => "${service_logs_dir}/commands.log",
          append     => true,
          layout     => '%d{ISO8601} [%t] %-5p %c - %m%n',
        },
        'server-logger' => {
          type          => 'rollingfile',
          filename      => "${service_logs_dir}/rundeck.log",
          append        => true,
          layout        => '%d{ISO8601} [%t] %-5p %c - %m%n',
        },
        'audit' => {
          type          => 'rollingfile',
          filename      => "${service_logs_dir}/rundeck.audit.log",
          append        => true,
          layout        => '%d{ISO8601} - %m%n',
        },
        'options' => {
          type          => 'rollingfile',
          filename      => "${service_logs_dir}/rundeck.options.log",
          append        => true,
          layout        => '[%d{ISO8601}] %X{httpStatusCode} %X{contentLength}B %X{durationTime}ms %X{lastModifiedDateTime} [%X{jobName}] %X{url} %X{contentSHA1}%n',
        },
        'jobchanges' => {
          type          => 'rollingfile',
          filename      => "${service_logs_dir}/rundeck.jobs.log",
          append        => true,
          layout        => '[%d{ISO8601}] %X{user} %X{change} [%X{id}] %X{project} "%X{groupPath}/%X{jobName}" (%X{method})%n',
        },
        'apirequests' => {
          type          => 'rollingfile',
          filename      => "${service_logs_dir}/rundeck.api.log",
          append        => true,
          layout        => '[%d{ISO8601}] %X{remoteHost} %X{secure} %X{remoteUser} %X{authToken} %X{duration} %X{project} "%X{method} %X{uri}" (%X{userAgent})%n',
        },
        'webaccess' => {
          type          => 'rollingfile',
          filename      => "${service_logs_dir}/rundeck.access.log",
          append        => true,
          layout        => '[%d{ISO8601}] "%X{method} %X{uri}" %X{remoteHost} %X{secure} %X{remoteUser} %X{authToken} %X{duration} %X{project} [%X{contentType}] (%X{userAgent})%n',
        },
      },
    },
  }

  $keystore = '/etc/rundeck/ssl/keystore'
  $keystore_password = 'adminadmin'
  $key_password = 'adminadmin'
  $truststore = '/etc/rundeck/ssl/truststore'
  $truststore_password = 'adminadmin'

  $resource_sources = {}

  $server_web_context = undef
  $jvm_args = '-Xmx1024m -Xms256m -server'

  $java_home = undef

  $ssl_enabled = false
  $ssl_port = '4443'

  $package_source = 'https://dl.bintray.com/rundeck/rundeck-deb'

  $web_xml = "${rdeck_base}/exp/webapp/WEB-INF/web.xml"
  $security_role = 'user'
  $session_timeout = 30

  $rdeck_config_template = 'rundeck/rundeck-config.erb'

  $file_keystorage_dir = undef
}
