# == Class rundeck::config::global::file_keystore
#
# This private class is called from rundeck::config, used to manage the keys of
# the Rundeck key storage facility if a file-based backend is used
#
# === Parameters
#
# [*keys*]
#   A hash of key data values, with a minimum of the following properties:
#  * *$value*: the actual value of the key, either the plaintext password string for passwords, or the encrypted public/priviate key
#  * *$path*: a string representing the relative path of the key to the 'keys' directory
#  * *$data_type*: the data type of the key, one of 'password', 'public-key' or 'private-key'
#  * *$content_type*: MIME type of the content, either 'application/x-rundeck-data-password', 'application/pgp-keys' (for public keys)
#
# [*path*]
#   The Rundeck OS user group
#
# [*user*]
#   The Rundeck OS user
#
# Example:
# ```
# {
#   $key1 => {
#      $value        => 'secret',
#      $path         => 'myproject/passwords',
#      $data_type    => 'password',
#      $content_type => 'application/x-rundeck-data-password', },
#   $key2 => {
#      $value        => 'ssh-rsa Th1sIsn0tRe@alLyAnRSAk3y',
#      $path         => 'myproject/pubkeys',
#      $data_type    => 'public',
#      $content_type => 'application/pgp-keys', },
# }
# ```
#
#
# [*file_keystorage_dir*]
#    The default base directory for file-based key storage
#
class rundeck::config::global::file_keystore (
  $file_keystorage_dir = $rundeck::file_keystorage_dir,
  $group               = $rundeck::group,
  $keys                = $rundeck::file_keystorage_keys,
  $user                = $rundeck::user,
) {

  assert_private()

  File {
    ensure  => directory,
    mode    => '0775',
    owner   => $user,
    group   => $group,
    require => File[$file_keystorage_dir],
  }

  file { [
    "${file_keystorage_dir}/content",
    "${file_keystorage_dir}/content/keys",
    "${file_keystorage_dir}/meta",
    "${file_keystorage_dir}/meta/keys",
  ]: }

  create_resources(rundeck::file_keystore, $keys)
}
