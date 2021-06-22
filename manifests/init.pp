# @summary
#   Installs and configures Icinga Web 2.
#
# @param [Enum['file', 'syslog', 'php', 'none']] logging
#   Whether Icinga Web 2 should log to 'file', 'syslog' or 'php' (web server's error log). Setting 'none' disables logging.
#
# @param [Stdlib::Absolutepath] logging_file
#   If 'logging' is set to 'file', this is the target log file.
#
# @param [Enum['ERROR', 'WARNING', 'INFO', 'DEBUG']] logging_level
#   Logging verbosity. Possible values are 'ERROR', 'WARNING', 'INFO' and 'DEBUG'.
#
# @param [Pattern[/user|local[0-7]/]] logging_facility
#   Logging facility when using syslog. Possible values are 'user' or 'local0' up to 'local7'.
#
# @param [String] logging_application
#   Logging application name when using syslog.
#
# @param [Boolean] show_stacktraces
#   Whether to display stacktraces in the web interface or not.
#
# @param [Stdlib::Absolutepath] module_path
#   Path to module sources. Multiple paths must be separated by colon.
#
# @param [String] theme
#   The default theme setting. Users may override this settings.
#
# @param [Boolean] theme_disabled
#   Whether users can change themes or not.
#
# @param [Boolean] manage_repo
#   Deprecated, use manage_repos.
#
# @param [Boolean] manage_repos
#   When set to true this module will use the module icinga/puppet-icinga to manage repositories,
#   e.g. the release repo on packages.icinga.com repository by default, the EPEL repository or Backports.
#   For more information, see http://github.com/icinga/puppet-icinga.
#
# @param [Boolean] manage_package
#   If set to `false` packages aren't managed.
#
# @param [Optional[Array[String]]] extra_packages
#   An array of packages to install additionally.
#
# @param [Boolean] import_schema
#   Import database scheme. Make sure you have an existing database if you use this option.
#
# @param [Enum['mysql', 'pgsql']] db_type
#   Database type, can be either `mysql` or `pgsql`. This parameter is only used if `import_schema` is `true` or
#   `config_backend` is `db`.
#
# @param [Stdlib::Host] db_host
#   Database hostname. This parameter is only used if `import_schema` is `true` or
#   `config_backend` is `db`.
#
# @param [Stdlib::Port] db_port
#   Port of database host. This parameter is only used if `import_schema` is `true` or
#   `config_backend` is `db`.
#
# @param [String] db_name
#   Database name. This parameter is only used if `import_schema` is `true` or
#   `config_backend` is `db`.
#
# @param [Optional[String]] db_username
#   Username for database access. This parameter is only used if `import_schema` is `true` or
#   `config_backend` is `db`.
#
# @param [Optional[String]] db_password
#   Password for database access. This parameter is only used if `import_schema` is `true` or
#   `config_backend` is `db`.
#
# [*admin_username*]
#  Username for initial admin access. This parameter is only used if `import_schema` is `true` or
#  `config_backend` is `db`.
#
# [*admin_password*]
#  Password for initial admin access. This parameter is only used if `import_schema` is `true` or
#  `config_backend` is `db`.
#
# @param [Enum['ini', 'db']] config_backend
#   The global Icinga Web 2 preferences can either be stored in a database or in ini files. This parameter can either
#   be set to `db` or `ini`.
#
# @param [String] conf_user
#   By default this module expects Apache2 on the server. You can change the owner of the config files with this
#   parameter.
#
# @param [String] conf_group
#   Group membership of config files.
#
# @param [Optional[String]] default_domain
#   When using domain-aware authentication, you can set a default domain here.
#
# @param [Optional[Stdlib::Absolutepath]] cookie_path
#   Path to where cookies are stored.
#
# @example Use MySQL as backend for user authentication:
#   include ::mysql::server
#
#   mysql::db { 'icingaweb2':
#     user     => 'icingaweb2',
#     password => 'supersecret',
#     host     => 'localhost',
#     grant    => [ 'ALL' ],
#   }
#
#   class {'icingaweb2':
#     manage_repos  => true,
#     import_schema => true,
#     db_type       => 'mysql',
#     db_host       => 'localhost',
#     db_port       => 3306,
#     db_username   => 'icingaweb2',
#     db_password   => 'supersecret',
#     require       => Mysql::Db['icingaweb2'],
#   }
#
# @example Use PostgreSQL as backend for user authentication:
#   include ::postgresql::server
#
#   postgresql::server::db { 'icingaweb2':
#     user     => 'icingaweb2',
#     password => postgresql_password('icingaweb2', 'icingaweb2'),
#   }
#
#   class {'icingaweb2':
#     manage_repos  => true,
#     import_schema => true,
#     db_type       => 'pgsql',
#     db_host       => 'localhost',
#     db_port       => 5432,
#     db_username   => 'icingaweb2',
#     db_password   => 'icingaweb2',
#     require       => Postgresql::Server::Db['icingaweb2'],
#   }
#
class icingaweb2 (
  Stdlib::Absolutepath                      $module_path,
  Stdlib::Absolutepath                      $logging_file,
  String                                    $conf_user,
  String                                    $conf_group,
  Enum['file', 'syslog', 'php', 'none']     $logging             = 'file',
  Enum['ERROR', 'WARNING', 'INFO', 'DEBUG'] $logging_level       = 'INFO',
  Pattern[/user|local[0-7]/]                $logging_facility    = 'user',
  String                                    $logging_application = 'icingaweb2',
  Boolean                                   $show_stacktraces    = false,
  String                                    $theme               = 'Icinga',
  Boolean                                   $theme_disabled      = false,
  Boolean                                   $manage_repo         = false,
  Boolean                                   $manage_repos        = false,
  Boolean                                   $manage_package      = true,
  Optional[Array[String]]                   $extra_packages      = undef,
  Boolean                                   $import_schema       = false,
  Enum['mysql', 'pgsql']                    $db_type             = 'mysql',
  Stdlib::Host                              $db_host             = 'localhost',
  Stdlib::Port                              $db_port             = 3306,
  String                                    $db_name             = 'icingaweb2',
  Optional[String]                          $db_username         = undef,
  Optional[String]                          $db_password         = undef,
  String                                    $admin_username      = 'icingaadmin',
  String                                    $admin_password      = 'icinga',
  Enum['ini', 'db']                         $config_backend      = 'ini',
  Optional[String]                          $default_domain      = undef,
  Optional[Stdlib::Absolutepath]            $cookie_path         = undef,
) {

  require ::icingaweb2::globals

  if $manage_repos or $manage_repo {
    require ::icinga::repos
    if $manage_repo {
      deprecation('manage_repo', 'manage_repo is deprecated and will be replaced by manage_repos in the future.')
    }
  }

  class { '::icingaweb2::install': }
  -> class { '::icingaweb2::config': }

  contain ::icingaweb2::install
  contain ::icingaweb2::config
}
