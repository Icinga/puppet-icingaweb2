# @summary
#   Manages commandtransport configuration for the monitoring module.
#
# @param [String] commandtransport
#   The name of the commandtransport.
#
# @param [Enum['api', 'local']] transport
#   The transport type you wish to use. Either `api` or `local`.
#
# @param [Stdlib::Host] host
#   Hostname/ip for the transport. Only needed for api transport.
#
# @param [Stdlib::Port] port
#   Port for the transport. Only needed for api transport.
#
# @param [Optional[String]] username
#   Username for the transport. Only needed for api transport.
#
# @param [Optional[String]] password
#   Password for the transport. Only needed for api transport.
#
# @param [Stdlib::Absolutepath] path
#   Path for the transport. Only needed for local transport.
#
# @api private
#
define icingaweb2::module::monitoring::commandtransport(
  String                                       $commandtransport = $title,
  Enum['api', 'local']                         $transport        = 'api',
  Stdlib::Host                                 $host             = 'localhost',
  Stdlib::Port                                 $port             = 5665,
  Optional[String]                             $username         = undef,
  Optional[Variant[String, Sensitive[String]]] $password         = undef,
  Stdlib::Absolutepath                         $path             = '/var/run/icinga2/cmd/icinga2.cmd',
){

  $conf_dir        = $::icingaweb2::globals::conf_dir
  $module_conf_dir = "${conf_dir}/modules/monitoring"

  case $transport {
    'api': {
      $commandtransport_settings = {
        'transport' => $transport,
        'host'      => $host,
        'port'      => $port,
        'username'  => $username,
        'password'  => if $password =~ Sensitive { $password.unwrap } else { $password },
      }
    }
    'local': {
      $commandtransport_settings = {
        'transport' => $transport,
        'path'      => $path,
      }
    }
    default: {
      fail('The transport type you provided is not supported')
    }
  }

  icingaweb2::inisection { "monitoring-commandtransport-${commandtransport}":
    section_name => $commandtransport,
    target       => "${module_conf_dir}/commandtransports.ini",
    settings     => delete_undef_values($commandtransport_settings),
  }
}
