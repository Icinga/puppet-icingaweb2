[![Build Status](https://travis-ci.org/Icinga/puppet-icingaweb2.png?branch=main)](https://travis-ci.org/Icinga/puppet-icingaweb2)

# Icinga Web 2 Puppet Module

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with Icinga Web 2](#setup)
    * [What Icinga Web 2 affects](#what-icinga-web-2-affects)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference](#reference)
6. [Development - Guide for contributing to the module](#development)

## Overview

[Icinga Web 2] is the associated web interface for the open source
monitoring tool [Icinga 2]. This module helps with installing and managing
configuration of Icinga Web 2 and its modules on multiple operating systems.

### Description

This module installs and configures Icinga Web 2 on your Linux host by using the official packages from
[packages.icinga.com]. Dependend packages are installed as they are defined in the Icinga Web 2 package.

This module can manage all configurations files of Icinga Web 2 and import an initial database schema. It can install and
manage all official [modules](https://www.icinga.com/products/icinga-web-2-modules/) as well as modules developed by the
community.

### What's new in version 4.0.0

NOTICE: With this release come some breaking changes, please also read the CHANGELOG and test this new version with
your manifests beforehand.

The puppet module `icinga` is required. Some functions, data types and defined resources of this module are now used.
Depends on [#380](https://github.com/Icinga/puppet-icingaweb2/pull/380).

The additional services for the Director, reporting and x509 module are not optinal anymore. The service classes are
private now and cannot declared individually. However, in order to still manage the service new parameters `manage_service`,
`service_ensure` and `service_enable` are added. See [#281](https://github.com/Icinga/puppet-icingaweb2/issues/281) and
[#379](https://github.com/Icinga/puppet-icingaweb2/pull/379).

Support of INI files as configuration backend for user preferences is dropped. The parameter `config_backend` also dropped
because the only supported backend by Icinga Web is `db` since v2.11.0.

We switched the default logging to `syslog`. Done in [#376](https://github.com/Icinga/puppet-icingaweb2/pull/376).

All parameters `db_type` must be set now ([#373](https://github.com/Icinga/puppet-icingaweb2/pull/376)), e.g. for `icingaweb2`,
`icingaweb2::module::monitoring` and all other modules that require a database.

The default location of all private keys and certificates for authentication or validation has changed
to `/var/lib/icingaweb2/<module name>/`. For more details [#380](https://github.com/Icinga/puppet-icingaweb2/pull/380).

Support of earlier version of Icinga Web as v2.9.0 is dropped. So we also removed the module classes of ipl, reactbundle and
incubator. If you use Icinga Web modules installed from git that require the incubator, please use `icingaweb2::extra_packages`
to install the official package `icinga-php-incubator`.

For more flexibility, we have added a parameter `db_resource_name` for an individual name for the automatically maintained Icinga Web resources, e.g.
the database resources for the Icinga Web backend, the Director database and so on. As a result, the default names have also changed.

### What's new in version 3.9.1

The Icinga team removed package icingaweb2-module-monitoring (only on Debian/Ubuntu) for Icinga Web 2 >= 2.12.0. For now
we add an parameter `manage_package` (set to `true` bye default) to do not managed the missing transition package.

## Setup

### What the Icinga 2 Puppet module supports

* Installation of Icinga Web 2 via packages
* Configuration
* MySQL / PostgreSQL database schema import
* Install and manage official Icinga Web 2 modules
* Install community modules

### Dependencies

This module depends on

* [icinga/icinga] >= 2.9.0 < 5.0.0
* [puppetlabs/stdlib] >= 6.6.0 < 10.0.0
* [puppetlabs/vcsrepo] >= 3.2.0 < 7.0.0
  * required if modules use `git` (default) as `install_method`.
  * [puppetlabs/concat] >= 6.4.0 < 10.0.0
* [puppet/systemd] >= 3.1.0 < 7.0.0


### Limitations

This module has been tested on:

* Debian 10, 11, 12
* CentOS/RHEL 7
  * Requires [Software Collections Repository](https://wiki.centos.org/AdditionalResources/Repositories/SCL)
* RHEL/AlmaLinux/Rocky 8, 9
  * Requires an [Icinga Subscription](https://icinga.com/subscription) for all versions >= 2.9.5 of Icinga Web 2.
* Ubuntu 20.04, 22.04

Other operating systems or versions may work but have not been tested.

## Usage

NOTE: If you plan to use additional modules from git, the CLI `git` command has to be installed. You can manage it yourself as package resource or declare the package name in `extra_packages`.

By default, your distribution's packages are used to install Icinga Web 2.

Use the `manage_repos` parameter to configure repositories by default the official and stable [packages.icinga.com]. To configure your own
repositories, or use the official testing or nightly snapshot stage, see https://github.com/icinga/puppet-icinga.

``` puppet
class { '::icingaweb2':
  manage_repos => true,
}
```

The usage of this module isn't simple. That depends on how Icinga Web 2 is implemented. Monitoring is here just a module in a framework. All basic stuff like authentication, logging or authorization is done by this framework. To store user and usergroups in a MySQL database, the database has to exist:
```
mysql::db { 'icingaweb2':
  user     => 'icingaweb2',
  password => 'supersecret',
  host     => 'localhost',
  grant    => [ 'ALL' ],
}

class { 'icingaweb2':
  manage_repos   => true,
  import_schema  => true,
  db_type        => 'mysql',
  db_host        => 'localhost',
  db_port        => 3306,
  db_username    => 'icingaweb2',
  db_password    => 'supersecret',
  extra_packages => [ 'git' ],
  require        => Mysql::Db['icingaweb2'],
}
```
If you set `import_schema` to `true` an default admin user `icingaadmin` with password `icinga` will be created automatically and you're allowed to login.

In case that `import_schema` is disabled or you'd like to use a different backend for authorization like LDAP, more work is required. At first we need a ressource with credentials to connect a LDAP server:
```
class {'icingaweb2':
  manage_repos   => true,
}

icingaweb2::resource::ldap { 'my-ldap':
  type    => 'ldap',
  host    => 'localhost',
  port    => 389,
  root_dn => 'ou=users,dc=icinga,dc=com',
  bind_dn => 'cn=icingaweb2,ou=users,dc=icinga,dc=com',
  bind_pw => 'supersecret',
}
```
With the help of this resource, we are now creating user and group backends. Users are permitted to login and users and groups will later be used for authorization.
```
icingaweb2::config::authmethod { 'ldap-auth':
  backend                  => 'ldap',
  resource                 => 'my-ldap',
  ldap_user_class          => 'user',
  ldap_filter              => '(memberof:1.2.840.113556.1.4.1941:=CN=monitoring,OU=groups,DC=icinga,DC=com)',
  ldap_user_name_attribute => 'cn',
  order                    => '05',
}

icingaweb2::config::groupbackend { 'ldap-groups':
  backend                     => 'ldap',
  resource                    => 'my-ldap',
  ldap_group_class            => 'group',
  ldap_group_name_attribute   => 'cn',
  ldap_group_member_attribute => 'member',
  ldap_base_dn                => 'ou=groups,dc=icinga,dc=com',
  domain                      => 'icinga.com',
}
```
A role must be managed for a group to receive admin rights:
```
icingaweb2::config::role { 'default admin user':
  groups      => 'icingaadmins',
  permissions => '*',
  parent      => 'default protection',
}
```
But the values of some custom variables are not displayed via inheritance:
```
icingaweb2::config::role { 'default protection':
  filters => {
    'icingadb/protect/variables' => '*pw*, *pass*, community',
  }
}
```
All available permissions for module `icingadb` are listed [here](https://icinga.com/docs/icinga-db-web/latest/doc/04-Security).

Finally we configure the icingadb with the needed connection to the database and the redis server and an API user to send commands to Icinga 2:
```
class {'icingaweb2::module::icingadb':
  db_type     => 'mysql',
  db_host     => 'db.icinga.com',
  db_port     => 1800,
  db_name     => 'icinga2',
  db_username => 'icinga2',
  db_password => Sensitive('supersecret'),
  redis_host  => 'localhost',
  commandtransports => {
    icinga2 => {
      transport => 'api',
      username  => 'icingaweb2',
      password  => Sensitive('supersecret'),
    }
  },
}
```

## Reference

See [REFERENCE.md](https://github.com/Icinga/puppet-icingaweb2/blob/main/REFERENCE.md)

## Development

A roadmap of this project is located at https://github.com/Icinga/puppet-icingaweb2/milestones. Please consider
this roadmap when you start contributing to the project.

### Contributing

When contributing several steps such as pull requests and proper testing implementations are required.
Find a detailed step by step guide in [CONTRIBUTING.md].

### Testing

Testing is essential in our workflow to ensure a good quality. We use RSpec as well as Serverspec to test all components
of this module. For a detailed description see [TESTING.md].

### Release Notes

When releasing new versions we refer to [SemVer 1.0.0] for version numbers. All steps required when creating a new
release are described in [RELEASE.md]

See also [CHANGELOG.md]

### Authors

[AUTHORS] is generated on each release.


[Icinga 2]: https://www.icinga.com/products/icinga-2/
[Icinga Web 2]: https://www.icinga.com/products/icinga-web-2/
[icinga/icinga]: https://github.com/icinga/puppet-icinga/

[puppetlabs/stdlib]: https://github.com/puppetlabs/puppetlabs-stdlib
[puppetlabs/concat]: https://github.com/puppetlabs/puppetlabs-concat
[puppetlabs/vcsrepo]: https://forge.puppet.com/puppetlabs/vcsrepo
[puppetlabs/mysql]: https://github.com/puppetlabs/puppetlabs-mysql
[puppetlabs/puppetlabs-postgresql]: https://github.com/puppetlabs/puppetlabs-postgresql
[packages.icinga.com]: https://packages.icinga.com

[CHANGELOG.md]: CHANGELOG.md
[AUTHORS]: AUTHORS
[RELEASE.md]: RELEASE.md
[TESTING.md]: TESTING.md
[CONTRIBUTING.md]: CONTRIBUTING.md
