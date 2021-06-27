# @summary
#   Manages the monitoring module. This module is mandatory for probably every setup.
#
# @param [Enum['absent', 'present']] ensure
#   Enable or disable module.
#
# @param [Variant[String, Array[String]]] protected_customvars
#   Custom variables in Icinga 2 may contain sensible information. Set patterns for custom variables
#   that should be hidden in the web interface.
#
# @param [Enum['mysql', 'pgsql']] ido_type
#   Type of your IDO database. Either `mysql` or `pgsql`.
#
# @param [Optional[Stdlib::Host]] ido_host
#   Hostname of the IDO database.
#
# @param [Stdlib::Port] ido_port
#   Port of the IDO database.
#
# @param [Optional[String]] ido_db_name
#   Name of the IDO database.
#
# @param [Optional[String]] ido_db_username
#   Username for IDO DB connection.
#
# @param [Optional[String]] ido_db_password
#   Password for IDO DB connection.
#
# @param [Optional[String]] ido_db_charset
#   The character set to use for the database connection.
#
# @param [Hash] commandtransports
#   A hash of command transports.
#
# @note At first have a look at the [Monitoring module documentation](https://www.icinga.com/docs/icingaweb2/latest/modules/monitoring/doc/01-About/).
#
# @example This module is mandatory for almost every setup. It connects your Icinga Web interface to the Icinga 2 core. Current and history information are queried through the IDO database. Actions such as `Check Now`, `Set Downtime` or `Acknowledge` are send to the Icinga 2 API.
#
# Requirements:
#   * IDO feature in Icinga 2 (MySQL or PostgreSQL)
#   * `ApiUser` object in Icinga 2 with proper permissions
#
#   class {'icingaweb2::module::monitoring':
#     ido_host        => 'localhost',
#     ido_type        => 'mysql',
#     ido_db_name     => 'icinga2',
#     ido_db_username => 'icinga2',
#     ido_db_password => 'supersecret',
#     commandtransports => {
#       icinga2 => {
#         transport => 'api',
#         username  => 'icingaweb2',
#         password  => 'supersecret',
#       }
#     }
#   }
#
class icingaweb2::module::monitoring(
  Enum['absent', 'present']                    $ensure               = 'present',
  Variant[String, Array[String]]               $protected_customvars = ['*pw*', '*pass*', 'community'],
  Enum['mysql', 'pgsql']                       $ido_type             = 'mysql',
  Optional[Stdlib::Host]                       $ido_host             = undef,
  Stdlib::Port                                 $ido_port             = 3306,
  Optional[String]                             $ido_db_name          = undef,
  Optional[String]                             $ido_db_username      = undef,
  Optional[Variant[String, Sensitive[String]]] $ido_db_password      = undef,
  Optional[String]                             $ido_db_charset       = undef,
  Hash                                         $commandtransports    = {},
){

  $conf_dir        = $::icingaweb2::globals::conf_dir
  $module_conf_dir = "${conf_dir}/modules/monitoring"

  case $::osfamily {
    'Debian': {
      $install_method = 'package'
      $package_name   = 'icingaweb2-module-monitoring'
    }
    default: {
      $install_method = 'none'
      $package_name   = undef
    }
  }

  icingaweb2::config::resource { 'icingaweb2-module-monitoring':
    type        => 'db',
    db_type     => $ido_type,
    host        => $ido_host,
    port        => $ido_port,
    db_name     => $ido_db_name,
    db_username => $ido_db_username,
    db_password => if $ido_db_password =~ Sensitive { $ido_db_password.unwrap } else { $ido_db_password },
    db_charset  => $ido_db_charset,
  }

  $backend_settings = {
    'type'     => 'ido',
    'resource' => 'icingaweb2-module-monitoring',
  }

  $security_settings = {
    'protected_customvars' => $protected_customvars ? {
      String        => $protected_customvars,
      Array[String] => join($protected_customvars, ','),
    }
  }

  $settings = {
    'module-monitoring-backends' => {
      'section_name' => 'backends',
      'target'       => "${module_conf_dir}/backends.ini",
      'settings'     => delete_undef_values($backend_settings)
    },
    'module-monitoring-security' => {
      'section_name' => 'security',
      'target'       => "${module_conf_dir}/config.ini",
      'settings'     => delete_undef_values($security_settings)
    }
  }

  create_resources('icingaweb2::module::monitoring::commandtransport', $commandtransports)

  icingaweb2::module {'monitoring':
    ensure         => $ensure,
    install_method => $install_method,
    package_name   => $package_name,
    settings       => $settings,
  }
}
