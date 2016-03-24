# Author::    Liam Bennett (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT
#
# == Class: rundeck
#
# This will install rundeck (https://rundeck.org/) and manage its configuration and plugins
#
# === Requirements/Dependencies
#
# Currently requires the puppetlabs/stdlib module on the Puppet Forge in
# order to validate much of the the provided configuration.
#
# === Parameters
#
# [*acl_template*]
#   The template used for admin acl policy. Default is rundeck/aclpolicy.erb.
#
# [*api_template*]
#   The template used for apitoken acl policy. Default is rundeck/aclpolicy.erb.
#
# [*auth_config*]
#  A hash of the auth configuration.
#
# [*auth_types*]
#   The method used to authenticate to rundeck. Default is file.
#
# [*clustermode_enabled*]
#  Boolean value if set to true enables cluster mode
#
# [*grails_server_url*]
#  The url used in sending email notifications.
#
# [*group*]
#  The group permission that rundeck is installed as.
#
# [*java_home*]
#  Set the home directory of java.
#
# [*jvm_args*]
#  Extra arguments for the JVM.
#
# [*key_password*]
#  The default key password.
#
# [*key_storage_type*]
#  Type used to store secrets. Must be 'file' or 'db'
#
# [*keystore*]
#  Full path to the java keystore to be used by Rundeck.
#
# [*keystore_password*]
#  The password for the given keystore.
#
# [*mail_config*]
#  A hash of the notification email configuration.
#
# [*manage_default_admin_policy*]
#  Boolean value if set to true enables default admin policy management
#
# [*manage_default_api_policy*]
#  Boolean value if set to true enables default api policy management
#
# [*package_ensure*]
#  Ensure the state of the rundeck package, either present, absent or a specific version
#
# [*preauthenticated_config*]
#  A hash of the rundeck preauthenticated config mode
#
# [*projects*]
#  The hash of projects in your instance.
#
# [*projects_description*]
#  The description that will be set by default for any projects.
#
# [*projects_organization*]
#  The organization value that will be set by default for any projects.
#
# [*projects_storage_type*]
#  The storage type for any projects. Must be 'filesystem' or 'db'
#
# [*properties_dir*]
#  The path to the configuration directory where the properties file are stored.
#
# [*rd_loglevel*]
#  The log4j logging level to be set for the Rundeck application.
#
# [*rdeck_base*]
#  The installation directory for rundeck.
#
# [*rdeck_config_template*]
#  Allows you to override the rundeck-config template
#
# [*rdeck_home*]
#  directory under which the projects directories live.
#
# [*rdeck_profile_template*]
#  Allows you to override the profile template
#
# [*rss_enabled*]
#  Boolean value if set to true enables RSS feeds that are public (non-authenticated)
#
# [*security_config*]
#  A hash of the rundeck security configuration.
#
# [*security_role*]
#  Name of the role that is required for all users to be allowed access.
#
# [*server_web_context*]
#  Web context path to use, such as "/rundeck". http://host.domain:port/server_web_context
#
# [*service_logs_dir*]
#  The path to the directory to store logs.
#
# [*service_name*]
#  The name of the rundeck service.
#
# [*session_timeout*]
#  Session timeout is an expired time limit for a logged in Rundeck GUI user which as been inactive for a period of time.
#
# [*ssl_enabled*]
#  Enable ssl for the rundeck web application.
#
# [*truststore*]
#  The full path to the java truststore to be used by Rundeck.
#
# [*truststore_password*]
#  The password for the given truststore.
#
# [*user*]
#  The user that rundeck is installed as.
#.
class rundeck (
  $acl_policies                 = $rundeck::params::acl_policies,
  $acl_template                 = $rundeck::params::acl_template,
  $api_policies                 = $rundeck::params::api_policies,
  $api_template                 = $rundeck::params::api_template,
  $auth_config                  = $rundeck::params::auth_config,
  $auth_template                = $rundeck::params::auth_template,
  $auth_types                   = $rundeck::params::auth_types,
  $clustermode_enabled          = $rundeck::params::clustermode_enabled,
  $database_config              = $rundeck::params::database_config,
  $file_keystorage_dir          = $rundeck::params::file_keystorage_dir,
  $file_keystorage_keys         = $rundeck::params::file_keystorage_keys,
  $grails_server_url            = $rundeck::params::grails_server_url,
  $group                        = $rundeck::params::group,
  $java_home                    = $rundeck::params::java_home,
  $jvm_args                     = $rundeck::params::jvm_args,
  $key_password                 = $rundeck::params::key_password,
  $key_storage_type             = $rundeck::params::key_storage_type,
  $keystore                     = $rundeck::params::keystore,
  $keystore_password            = $rundeck::params::keystore_password,
  $logs_dir                     = $rundeck::params::logs_dir,
  $mail_config                  = $rundeck::params::mail_config,
  $manage_default_admin_policy  = $rundeck::params::manage_default_admin_policy,
  $manage_default_api_policy    = $rundeck::params::manage_default_api_policy,
  $manage_yum_repo              = $rundeck::params::manage_yum_repo,
  $package_ensure               = $rundeck::params::package_ensure,
  $package_source               = $rundeck::params::package_source,
  $preauthenticated_config      = $rundeck::params::preauthenticated_config,
  $projects                     = $rundeck::params::projects,
  $projects_description         = $rundeck::params::projects_description,
  $projects_dir                 = $rundeck::params::projects_dir,
  $projects_organization        = $rundeck::params::projects_organization,
  $projects_storage_type        = $rundeck::params::projects_storage_type,
  $properties_dir               = $rundeck::params::properties_dir,
  $rd_loglevel                  = $rundeck::params::loglevel,
  $rdeck_base                   = $rundeck::params::rdeck_base,
  $rdeck_config_template        = $rundeck::params::rdeck_config_template,
  $rdeck_home                   = $rundeck::params::rdeck_home,
  $rdeck_profile_template       = $rundeck::params::rdeck_profile_template,
  $realm_template               = $rundeck::params::realm_template,
  $rss_enabled                  = $rundeck::params::rss_enabled,
  $security_config              = $rundeck::params::security_config,
  $security_role                = $rundeck::params::security_role,
  $server_hostname              = $rundeck::params::server_hostname,
  $server_name                  = $rundeck::params::server_name,
  $server_port                  = $rundeck::params::server_port,
  $server_url                   = $rundeck::params::server_url,
  $server_uuid                  = $rundeck::params::server_uuid,
  $server_web_context           = $rundeck::params::server_web_context,
  $service_config               = $rundeck::params::service_config,
  $service_logs_dir             = $rundeck::params::service_logs_dir,
  $service_name                 = $rundeck::params::service_name,
  $service_script               = $rundeck::params::service_script,
  $session_timeout              = $rundeck::params::session_timeout,
  $ssh_keypath                  = $rundeck::params::ssh_keypath,
  $ssh_user                     = $rundeck::params::ssh_user,
  $ssh_timeout                  = $rundeck::params::ssh_timeout,
  $ssl_enabled                  = $rundeck::params::ssl_enabled,
  $truststore                   = $rundeck::params::truststore,
  $truststore_password          = $rundeck::params::truststore_password,
  $user                         = $rundeck::params::user,
) inherits rundeck::params {

  validate_rd_policy($acl_policies)
  validate_string($acl_template)
  validate_rd_policy($api_policies)
  validate_string($api_template)
  validate_hash($auth_config)
  validate_string($auth_template)
  validate_array($auth_types)
  validate_bool($clustermode_enabled)
  validate_hash($database_config)
  validate_absolute_path($file_keystorage_dir)
  validate_hash($file_keystorage_keys)
  validate_string($grails_server_url)
  validate_re($group, '[a-zA-Z0-9]{3,}')
  validate_re($key_storage_type, [ '^db$', '^file$' ])
  validate_string($key_password)
  validate_absolute_path($keystore)
  validate_string($keystore_password)
  validate_hash($mail_config)
  validate_bool($manage_default_admin_policy)
  validate_bool($manage_default_api_policy)
  validate_bool($manage_yum_repo)
  validate_string($package_ensure)
  validate_string($package_source)
  validate_hash($preauthenticated_config)
  validate_hash($projects)
  validate_string($projects_description)
  validate_absolute_path($projects_dir)
  validate_string($projects_organization)
  validate_re($projects_storage_type, [ '^db$', '^filesystem$' ])
  validate_absolute_path($properties_dir)
  validate_re($rd_loglevel, [ '^ALL$', '^DEBUG$', '^ERROR$', '^FATAL$', '^INFO$', '^OFF$', '^TRACE$', '^WARN$' ])
  validate_absolute_path($rdeck_base)
  validate_string($rdeck_config_template)
  validate_absolute_path($rdeck_home)
  validate_string($rdeck_profile_template)
  validate_string($realm_template)
  validate_bool($rss_enabled)
  validate_hash($security_config)
  validate_string($security_role)
  validate_string($server_hostname)
  validate_string($server_name)
  validate_integer($server_port)
  validate_string($server_url)
  validate_string($server_uuid)
  validate_string($server_web_context)
  validate_string($service_config)
  validate_absolute_path($service_logs_dir)
  validate_string($service_name)
  validate_string($service_script)
  validate_integer($session_timeout)
  validate_absolute_path($ssh_keypath)
  validate_integer($ssh_timeout)
  validate_re($ssh_user, '[a-zA-Z0-9]{3,}')
  validate_bool($ssl_enabled)
  validate_absolute_path($truststore)
  validate_string($truststore_password)
  validate_re($user, '[a-zA-Z0-9]{3,}')

  class { '::rundeck::install': } ->
  class { '::rundeck::config': } ~>
  class { '::rundeck::service': } ->
  Class['rundeck']
}
