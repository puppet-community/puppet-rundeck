# @api private
#
# @summary This class is called from rundeck to manage the configuration.
#
class rundeck::config {
  assert_private()

  $auth_types     = $rundeck::auth_config.keys.unique
  $properties_dir = $rundeck::framework_config['framework.etc.dir']

  File {
    owner  => $rundeck::user,
    group  => $rundeck::group,
    mode   => '0644',
  }

  if $rundeck::manage_home {
    file { $rundeck::home_dir:
      ensure => directory,
      mode   => '0755',
    }
  }

  [$rundeck::service_logs_dir, $properties_dir].each |$_path| {
    file { $_path:
      ensure => directory,
      mode   => '0755',
    }
  }

  if any(['file', 'ldap_shared', 'active_directory_shared']) |$_type| {
    $_type in $auth_types
  } {
    file { "${properties_dir}/realm.properties":
      content => Sensitive(epp($rundeck::realm_template, { auth_config => $rundeck::auth_config })),
      require => File[$properties_dir],
    }
  } else {
    file { "${properties_dir}/realm.properties":
      ensure => absent,
    }
  }

  case $auth_types {
    'file': {
      $active_directory_auth_flag = 'sufficient'
      $ldap_auth_flag = 'sufficient'
    }
    'active_directory': {
      $active_directory_auth_flag = 'required'
      $ldap_auth_flag = 'sufficient'
      $ldap_login_module = 'JettyCachingLdapLoginModule'
    }
    'active_directory_shared': {
      $active_directory_auth_flag = 'requisite'
      $ldap_auth_flag = 'sufficient'
      $ldap_login_module = 'JettyCombinedLdapLoginModule'
    }
    'ldap_shared': {
      $ldap_auth_flag = 'requisite'
      $ldap_login_module = 'JettyCombinedLdapLoginModule'
    }
    'ldap': {
      $ldap_auth_flag = 'required'
      $ldap_login_module = 'JettyCachingLdapLoginModule'
    }
    default: {}
  }

  file { "${properties_dir}/jaas-auth.conf":
    content => epp($rundeck::auth_template, { auth_config => $rundeck::auth_config }),
    require => File[$properties_dir],
  }

  # file { "${properties_dir}/log4j.properties":
  #   content => template($rundeck::log_properties_template),
  #   require => File[$properties_dir],
  # }

  # if $rundeck::manage_default_admin_policy {
  #   rundeck::config::aclpolicyfile { 'admin':
  #     acl_policies   => $rundeck::admin_policies,
  #     owner          => $rundeck::user,
  #     group          => $rundeck::group,
  #     properties_dir => $properties_dir,
  #     template_file  => $rundeck::acl_template,
  #   }
  # }

  # if $rundeck::manage_default_api_policy {
  #   rundeck::config::aclpolicyfile { 'apitoken':
  #     acl_policies   => $rundeck::api_policies,
  #     owner          => $rundeck::user,
  #     group          => $rundeck::group,
  #     properties_dir => $properties_dir,
  #     template_file  => $rundeck::acl_template,
  #   }
  # }

  # if ($rundeck::rdeck_profile_template) {
  #   file { "${properties_dir}/profile":
  #     content => template($rundeck::rdeck_profile_template),
  #     require => File[$properties_dir],
  #   }
  # }

  # if ($rundeck::rdeck_override_template) {
  #   file { "${rundeck::overrides_dir}/${rundeck::service_name}":
  #     content => template($rundeck::rdeck_override_template),
  #   }
  # }

  # contain rundeck::config::global::framework
  # contain rundeck::config::global::project
  # contain rundeck::config::global::rundeck_config
  # contain rundeck::config::global::file_keystore

  # Class['rundeck::config::global::framework']
  # -> Class['rundeck::config::global::project']
  # -> Class['rundeck::config::global::rundeck_config']
  # -> Class['rundeck::config::global::file_keystore']

  # if $ssl_enabled {
  #   contain rundeck::config::global::ssl
  #   Class['rundeck::config::global::rundeck_config']
  #   -> Class['rundeck::config::global::ssl']
  # }

  # create_resources(rundeck::config::project, $projects)

  # if versioncmp( $package_ensure, '3.0.0' ) < 0 {
  #   class { 'rundeck::config::global::web':
  #     security_role                => $security_role,
  #     session_timeout              => $session_timeout,
  #     security_roles_array_enabled => $security_roles_array_enabled,
  #     security_roles_array         => $security_roles_array,
  #     require                      => Class['rundeck::install'],
  #   }
  # }

  # if !empty($kerberos_realms) {
  #   file { "${properties_dir}/krb5.conf":
  #     owner   => $user,
  #     group   => $group,
  #     mode    => '0640',
  #     content => template('rundeck/krb5.conf.erb'),
  #     require => File[$properties_dir],
  #   }
  # }
}
