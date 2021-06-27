# @summary
#   Manages an Elasticsearch instance
#
# @param [String] instance_name
#   Name of the Elasticsearch instance
#
# @param [String] uri
#   URI to the Elasticsearch instance
#
# @param [Optional[String]] user
#   The user to use for authentication
#
# @param [Optional[String]] password
#   The password to use for authentication
#
# @param [Optional[Stdlib::Absolutepath]] ca
#   The path of the file containing one or more certificates to verify the peer with or the path to the directory
#   that holds multiple CA certificates.
#
# @param [Optional[Stdlib::Absolutepath]] client_certificate
#   The path of the client certificates
#
# @param [Optional[Stdlib::Absolutepath]] client_private_key
#   The path of the client private key
#
# @api private
#
define icingaweb2::module::elasticsearch::instance(
  String                                       $instance_name      = $title,
  String                                       $uri                = undef,
  Optional[String]                             $user               = undef,
  Optional[Variant[String, Sensitive[String]]] $password           = undef,
  Optional[Stdlib::Absolutepath]               $ca                 = undef,
  Optional[Stdlib::Absolutepath]               $client_certificate = undef,
  Optional[Stdlib::Absolutepath]               $client_private_key = undef,
){

  assert_private("You're not supposed to use this defined type manually.")

  $conf_dir        = $::icingaweb2::globals::conf_dir
  $module_conf_dir = "${conf_dir}/modules/elasticsearch"

  $instance_settings = {
    'uri'                => $uri,
    'user'               => $user,
    'password'           => if $password =~ Sensitive { $password.unwrap } else { $password },
    'ca'                 => $ca,
    'client_certificate' => $client_certificate,
    'client_private_key' => $client_private_key,
  }

  icingaweb2::inisection { "elasticsearch-instance-${instance_name}":
    section_name => $instance_name,
    target       => "${module_conf_dir}/instances.ini",
    settings     => delete_undef_values($instance_settings)
  }
}
