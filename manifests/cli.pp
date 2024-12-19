# @summary Class to manage installation and configuration of Rundeck CLI.
#
# @example Use cli with token and project config.
#   class { 'rundeck::cli':
#     manage_repo => false,
#     url         => 'https://rundeck01.example.com',
#     bypass_url  => 'https://rundeck.example.com',
#     token       => 'very_secure',
#     projects    => {
#       'MyProject'   => {
#         'update_method' => 'set',
#         'config'        => {
#           'project.description'        => 'This is My rundeck project',
#           'project.disable.executions' => 'false',
#         },
#       },
#       'TestProject' => {
#         'config' => {
#           'project.description'      => 'This is a rundeck test project',
#           'project.disable.schedule' => 'false',
#         },
#       },
#     },
#   }
#
# @param repo_config
#   A hash of repository attributes for configuring the rundeck cli package repositories.
#   Examples/defaults for yumrepo can be found at RedHat.yaml, and for apt at Debian.yaml
# @param manage_repo
#   Whether to manage the cli package repository.
# @param notify_conn_check
#   Wheter to notify the cli connection check if rundeck service changes.
# @param version
#   Ensure the state of the rundeck cli package, either present, absent or a specific version.
# @param url
#   Rundeck instance/api url.
# @param bypass_url
#   Rundeck external url to bypass. This will rewrite any redirect to $bypass_url as $url
# @param user
#   Cli user to authenticate.
# @param password
#   Cli password to authenticate.
# @param token
#   Cli token to authenticate.
# @param projects
#   Cli projects config. See example for structure and rundeck::config::project for available params.
#
class rundeck::cli (
  Hash $repo_config,
  Boolean $manage_repo = true,
  Boolean $notify_conn_check = false,
  String[1] $version = 'installed',
  Stdlib::HTTPUrl $url = 'http://localhost:4440',
  Stdlib::HTTPUrl $bypass_url = 'http://localhost:4440',
  String[1] $user = 'admin',
  String[1] $password = 'admin',
  Optional[String[8]] $token = undef,
  Hash[String, Rundeck::Project] $projects = {},
) {
  ensure_resource('package', 'jq', { 'ensure' => 'installed' })

  if $notify_conn_check {
    Class['rundeck::service'] ~> Exec['Check rundeck cli connection']
  }

  case $facts['os']['family'] {
    'RedHat': {
      if $manage_repo {
        $repo_config.each | String $_repo_name, Hash $_attributes| {
          yumrepo { $_repo_name:
            *      => $_attributes,
            before => Package['rundeck-cli'],
          }
        }
      }
    }
    'Debian': {
      if $manage_repo {
        $repo_config.each | String $_repo_name, Hash $_attributes| {
          apt::source { $_repo_name:
            *      => $_attributes,
            before => Package['rundeck-cli'],
          }
        }
      }

      Class['Apt::Update'] -> Package['rundeck-cli']
    }
    default: {
      err("The osfamily: ${facts['os']['family']} is not supported")
    }
  }

  package { 'rundeck-cli':
    ensure => $version,
  }

  file {
    default:
      ensure => file,
      mode   => '0755',
      ;
    '/usr/local/bin/rd_project_diff.sh':
      content => file('rundeck/rd_project_diff.sh'),
      ;
    '/usr/local/bin/rd_job_diff.sh':
      content => file('rundeck/rd_job_diff.sh'),
      ;
    '/usr/local/bin/rd_scm_diff.sh':
      content => file('rundeck/rd_scm_diff.sh'),
      ;
  }

  $_default_env_vars = [
    'RD_FORMAT=json',
    "RD_URL=${url}",
    "RD_BYPASS_URL=${bypass_url}",
  ]

  if $token {
    $environment = $_default_env_vars + ["RD_TOKEN=${token}"]
  } else {
    $environment = $_default_env_vars + ["RD_USER=${user}", "RD_PASSWORD=${password}"]
  }

  exec { 'Check rundeck cli connection':
    command     => 'rd system info',
    path        => ['/bin', '/usr/bin', '/usr/local/bin'],
    environment => $environment,
    tries       => 60,
    try_sleep   => 5,
    unless      => 'rd system info &> /dev/null',
    require     => Package['rundeck-cli'],
  }

  $projects.each |$_name, $_attr| {
    rundeck::config::project { $_name:
      *       => $_attr,
      require => Exec['Check rundeck cli connection'],
    }
  }
}
