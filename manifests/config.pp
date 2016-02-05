# Author::    Liam Bennett (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class rundeck::config
#
# This private class is called from `rundeck` to manage the configuration
#
class rundeck::config(
  $auth_types            = $rundeck::auth_types,
  $auth_template         = $rundeck::auth_template,
  $realm_template        = $rundeck::realm_template,
  $user                  = $rundeck::user,
  $group                 = $rundeck::group,
  $server_web_context    = $rundeck::server_web_context,
  $jvm_args              = $rundeck::jvm_args,
  $java_home             = $rundeck::java_home,
  $ssl_enabled           = $rundeck::ssl_enabled,
  $projects              = $rundeck::projects,
  $projects_organization = $rundeck::projects_default_org,
  $projects_description  = $rundeck::projects_default_desc,
  $rd_loglevel           = $rundeck::rd_loglevel,
  $rss_enabled           = $rundeck::rss_enabled,
  $clustermode_enabled   = $rundeck::clustermode_enabled,
  $grails_server_url     = $rundeck::grails_server_url,
  $database_config       = $rundeck::database_config,
  $keystore              = $rundeck::keystore,
  $keystore_password     = $rundeck::keystore_password,
  $key_password          = $rundeck::key_password,
  $truststore            = $rundeck::truststore,
  $truststore_password   = $rundeck::truststore_password,
  $service_logs_dir      = $rundeck::service_logs_dir,
  $file_keystorage_dir   = $rundeck::file_keystorage_dir,
  $service_name          = $rundeck::service_name,
  $mail_config           = $rundeck::mail_config,
  $security_config       = $rundeck::security_config,
  $security_role         = $rundeck::security_role,
  $session_timeout       = $rundeck::session_timeout,
  $acl_policies          = $rundeck::acl_policies,
  $api_policies          = $rundeck::api_policies,
  $rdeck_config_template = $rundeck::rdeck_config_template,
) inherits rundeck::params {

  $framework_config = deep_merge($rundeck::params::framework_config, $rundeck::framework_config)
  $auth_config      = deep_merge($rundeck::params::auth_config, $rundeck::auth_config)

  $logs_dir       = $framework_config['framework.logs.dir']
  $rdeck_base     = $framework_config['rdeck.base']
  $projects_dir   = $framework_config['framework.projects.dir']
  $properties_dir = $framework_config['framework.etc.dir']

  ensure_resource('file', $properties_dir, {'ensure' => 'directory', 'owner' => $user, 'group' => $group} )

  #
  # Checking if we need to deploy realm file
  #  ugly, I know. Fix it if you know better way to do that
  #
  if 'file' in $auth_types or 'ldap_shared' in $auth_types or 'active_directory_shared' in $auth_types {
    $_deploy_realm = true
  }
  if $_deploy_realm {
    file { "${properties_dir}/realm.properties":
      owner   => $user,
      group   => $group,
      mode    => '0640',
      content => template($realm_template),
      require => File[$properties_dir],
      notify  => Service[$service_name],
    }
  }

  if 'file' in $auth_types {
    $active_directory_auth_flag = 'sufficient'
    $ldap_auth_flag = 'sufficient'
  } else {
    if 'active_directory' in $auth_types {
      $active_directory_auth_flag = 'required'
      $ldap_auth_flag = 'sufficient'
    }
    elsif 'active_directory_shared' in $auth_types {
      $active_directory_auth_flag = 'requisite'
      $ldap_auth_flag = 'sufficient'
    }
    elsif 'ldap_shared' in $auth_types {
      $ldap_auth_flag = 'requisite'
    }
    elsif 'ldap' in $auth_types {
      $ldap_auth_flag = 'required'
    }
  }

  if 'active_directory' in $auth_types or 'ldap' in $auth_types {
    $ldap_login_module = 'JettyCachingLdapLoginModule'
  }
  elsif 'active_directory_shared' in $auth_types or 'ldap_shared' in $auth_types {
    $ldap_login_module = 'JettyCombinedLdapLoginModule'
  }
  file { "${properties_dir}/jaas-auth.conf":
    owner   => $user,
    group   => $group,
    mode    => '0640',
    content => template($auth_template),
    require => File[$properties_dir],
  }

  file { "${properties_dir}/log4j.properties":
    owner   => $user,
    group   => $group,
    mode    => '0640',
    content => template('rundeck/log4j.properties.erb'),
    notify  => Service[$service_name],
    require => File[$properties_dir],
  }

  rundeck::config::aclpolicyfile { 'admin':
    acl_policies   => $acl_policies,
    owner          => $user,
    group          => $group,
    properties_dir => $properties_dir,
  }

  rundeck::config::aclpolicyfile { 'apitoken':
    acl_policies   => $api_policies,
    owner          => $user,
    group          => $group,
    properties_dir => $properties_dir,
  }

  file { "${properties_dir}/profile":
    owner   => $user,
    group   => $group,
    mode    => '0640',
    content => template('rundeck/profile.erb'),
    notify  => Service[$service_name],
    require => File[$properties_dir],
  }

  include '::rundeck::config::global::framework'
  include '::rundeck::config::global::project'
  include '::rundeck::config::global::rundeck_config'

  Class[rundeck::config::global::framework] ->
  Class[rundeck::config::global::project] ->
  Class[rundeck::config::global::rundeck_config]

  if $ssl_enabled {
    include '::rundeck::config::global::ssl'
    Class[rundeck::config::global::rundeck_config] ->
    Class[rundeck::config::global::ssl]
  }

  create_resources(rundeck::config::project, $projects)

  class { '::rundeck::config::global::web':
    security_role   => $security_role,
    session_timeout => $session_timeout,
    notify          => Service[$service_name],
  }
}
