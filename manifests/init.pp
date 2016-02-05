# Author::    Liam Bennett (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class: rundeck
#
# This will install rundeck (http://rundeck.org/) and manage it's configration and plugins
#
# === Requirements/Dependencies
#
# Currently reequires the puppetlabs/stdlib module on the Puppet Forge in
# order to validate much of the the provided configuration.
#
# === Parameters
#
# [*package_ensure*]
#   Ensure the state of the rundeck package, either present, absent or a specific version
#
# [*auth_types*]
#   The method used to authenticate to rundeck. Default is file.
#
# [*properties_dir*]
#   The path to the configuration directory where the properties file are stored.
#
# [*service_logs_dir*]
#   The path to the directory to store logs.
#
# [*user*]
#   The user that rundeck is installed as.
#
# [*group*]
#   The group that the rundeck user is a member of.
#
# [*jvm_args*]
#   Extra arguments for the JVM.
#
# [*java_home*]
#   Set the home directory of java.
#
# [*rdeck_base*]
#   The installation directory for rundeck.
#
# [*ssl_enabled*]
#   Enable ssl for the rundeck web application.
#
# [*projects*]
#  The hash of projects in your instance.
#
# [*projects_organization*]
#  The organization value that will be set by default for any projects.
#
# [*projects_description*]
#  The description that will be set by default for any projects.
#
# [*rd_loglevel*]
#  The log4j logging level to be set for the Rundeck application.
#
# [*rss_enabled*]
#  Boolean value if set to true enables RSS feeds that are public (non-authenticated)
#
# [*clustermode_enabled*]
#  Boolean value if set to true enables cluster mode
#
# [*grails_server_url*]
#  The url used in sending email notifications.
#
# [*keystore*]
#  Full path to the java keystore to be used by Rundeck.
#
# [*keystore_password*]
#  The password for the given keystore.
#
# [*key_password*]
#  The default key password.
#
# [*truststore*]
#  The full path to the java truststore to be used by Rundeck.
#
# [*truststore_password*]
#  The password for the given truststore.
#
# [*service_name*]
#  The name of the rundeck service.
#
# [*mail_config*]
#  A hash of the notification email configuraton.
#
# [*security_config*]
#  A hash of the rundeck security configuration.
#
# [*security_role*]
#  Name of the role that is required for all users to be allowed access.
#
# [*session_timeout*]
#  Session timeout is an expired time limit for a logged in Rundeck GUI user which as been inactive for a period of time.
#
# [*user*]
#   The user that rundeck is installed as.
#
# [*group*]
#   The group permission that rundeck is installed as.
#
# [*server_web_context*]
#   Web context path to use, such as "/rundeck". http://host.domain:port/server_web_context
#
# [*rdeck_home*]
#   directory under which the projects directories live.
#
class rundeck (
  $package_ensure               = $rundeck::params::package_ensure,
  $package_source               = $rundeck::params::package_source,
  $auth_types                   = $rundeck::params::auth_types,
  $auth_template                = $rundeck::params::auth_template,
  $auth_config                  = $rundeck::params::auth_config,
  $realm_template               = $rundeck::params::realm_template,
  $acl_policies                 = $rundeck::params::acl_policies,
  $acl_template                 = $rundeck::params::acl_template,
  $api_policies                 = $rundeck::params::api_policies,
  $api_template                 = $rundeck::params::api_template,
  $service_logs_dir             = $rundeck::params::service_logs_dir,
  $file_keystorage_dir          = $rundeck::params::file_keystorage_dir,
  $ssl_enabled                  = $rundeck::params::ssl_enabled,
  $framework_config             = $rundeck::params::framework_config,
  $projects                     = $rundeck::params::projects,
  $projects_organization        = $rundeck::params::projects_default_org,
  $projects_description         = $rundeck::params::projects_default_desc,
  $rd_loglevel                  = $rundeck::params::loglevel,
  $rss_enabled                  = $rundeck::params::rss_enabled,
  $clustermode_enabled          = $rundeck::params::clustermode_enabled,
  $grails_server_url            = $rundeck::params::grails_server_url,
  $database_config              = $rundeck::params::database_config,
  $keystore                     = $rundeck::params::keystore,
  $keystore_password            = $rundeck::params::keystore_password,
  $key_password                 = $rundeck::params::key_password,
  $truststore                   = $rundeck::params::truststore,
  $truststore_password          = $rundeck::params::truststore_password,
  $service_name                 = $rundeck::params::service_name,
  $service_manage               = $rundeck::params::service_manage,
  $service_script               = $rundeck::params::service_script,
  $service_config               = $rundeck::params::service_config,
  $mail_config                  = $rundeck::params::mail_config,
  $security_config              = $rundeck::params::security_config,
  $security_role                = $rundeck::params::security_role,
  $session_timeout              = $rundeck::params::session_timeout,
  $manage_yum_repo              = $rundeck::params::manage_yum_repo,
  $user                         = $rundeck::params::user,
  $group                        = $rundeck::params::group,
  $server_web_context           = $rundeck::params::server_web_context,
  $jvm_args                     = $rundeck::params::jvm_args,
  $java_home                    = $rundeck::params::java_home,
  $rdeck_home                   = $rundeck::params::rdeck_home,
  $rdeck_config_template        = $rundeck::params::rdeck_config_template,
  $file_keystorage_keys         = $rundeck::params::file_keystorage_keys,
) inherits rundeck::params {

  #validate_re($package_ensure, '\d+\.\d+\.\d+')

  validate_array($auth_types)
  validate_hash($auth_config)
  validate_bool($ssl_enabled)
  validate_hash($projects)
  validate_string($projects_organization)
  validate_string($projects_description)
  validate_re($rd_loglevel, ['^ALL$', '^DEBUG$', '^ERROR$', '^FATAL$', '^INFO$', '^OFF$', '^TRACE$', '^WARN$'])
  validate_bool($rss_enabled)
  validate_bool($clustermode_enabled)
  validate_string($grails_server_url)
  validate_hash($database_config)
  validate_absolute_path($keystore)
  validate_absolute_path($keystore)
  validate_string($keystore_password)
  validate_string($key_password)
  validate_absolute_path($truststore)
  validate_string($truststore_password)
  validate_string($service_name)
  validate_string($package_ensure)
  validate_hash($mail_config)
  validate_string($user)
  validate_string($group)
  validate_string($server_web_context)
  validate_absolute_path($rdeck_home)
  validate_rd_policy($acl_policies)
  validate_hash($file_keystorage_keys)

  class { '::rundeck::facts': } ->
  class { '::rundeck::install': } ->
  class { '::rundeck::config': } ~>
  class { '::rundeck::service': } ->
  Class['rundeck']
}
