# @summary
#   The Graphite module draws graphs out of time series data stored in Graphite.
#
# @note If you want to use `git` as `install_method`, the CLI `git` command has to be installed. You can manage it yourself as package resource or declare the package name in icingaweb2 class parameter `extra_packages`.
#
# @param ensure
#   Enables or disables module.
#
# @param module_dir
#   Target directory of the module.
#
# @param git_repository
#   Set a git repository URL.
#
# @param git_revision
#   Set either a branch or a tag name, eg. `master` or `v1.3.2`.   
#
# @param install_method
#   Install methods are `git`, `package` and `none` is supported as installation method.
#
# @param package_name
#   Package name of the module. This setting is only valid in combination with the installation method `package`.
#
# @param url
#   URL to your Graphite Web/API.
#
# @param user
#   A user with access to your Graphite Web via HTTP basic authentication.
#
# @param password
#   The users password.
#
# @param graphite_writer_host_name_template
#    The value of your Icinga 2 GraphiteWriter's attribute `host_name_template` (if specified).
#
# @param graphite_writer_service_name_template
#   The value of your icinga 2 GraphiteWriter's attribute `service_name_template` (if specified).
#
# @note Here the official [Graphite module documentation](https://www.icinga.com/docs/graphite/latest/) can be found.
#
# @example
#   class { 'icingaweb2::module::graphite':
#     git_revision => 'v0.9.0',
#     url          => 'https://localhost:8080'
#   }
#
class icingaweb2::module::graphite (
  Enum['absent', 'present']      $ensure                                = 'present',
  Optional[Stdlib::Absolutepath] $module_dir                            = undef,
  String                         $git_repository                        = 'https://github.com/Icinga/icingaweb2-module-graphite.git',
  Optional[String]               $git_revision                          = undef,
  Enum['git', 'none', 'package'] $install_method                        = 'git',
  String                         $package_name                          = 'icingaweb2-module-graphite',
  Optional[String]               $url                                   = undef,
  Optional[String]               $user                                  = undef,
  Optional[Icingaweb2::Secret]   $password                              = undef,
  Optional[String]               $graphite_writer_host_name_template    = undef,
  Optional[String]               $graphite_writer_service_name_template = undef
) {
  $conf_dir        = $icingaweb2::globals::conf_dir
  $module_conf_dir = "${conf_dir}/modules/graphite"

  $graphite_settings = {
    'url'      => $url,
    'user'     => $user,
    'password' => icingaweb2::unwrap($password),
  }

  $icinga_settings = {
    'graphite_writer_host_name_template'    => $graphite_writer_host_name_template,
    'graphite_writer_service_name_template' => $graphite_writer_service_name_template,
  }

  $settings = {
    'module-graphite-graphite' => {
      'section_name' => 'graphite',
      'target'       => "${module_conf_dir}/config.ini",
      'settings'     => delete_undef_values($graphite_settings),
    },
    'module-graphite-icinga' => {
      'section_name' => 'icinga',
      'target'       => "${module_conf_dir}/config.ini",
      'settings'     => delete_undef_values($icinga_settings),
    },
  }

  icingaweb2::module { 'graphite':
    ensure         => $ensure,
    git_repository => $git_repository,
    git_revision   => $git_revision,
    install_method => $install_method,
    module_dir     => $module_dir,
    package_name   => $package_name,
    settings       => $settings,
  }
}
