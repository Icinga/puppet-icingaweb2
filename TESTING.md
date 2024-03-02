# TESTING

## Prerequisites
Before starting any test, you should make sure you have installed the Puppet PDK and Bolt,
also Vagrant and VirtualBox have to be installed for acceptance tests.

Required gems are installed with `bundler`:
```
cd puppet-icingaweb2
pdk bundle install
```

Or just do an update:
```
cd puppet-icingaweb2
pdk bundle update
```

## Validation tests
Validation tests will check all manifests, templates and ruby files against syntax violations and style guides .

Run validation tests:
```
cd puppet-icingaweb2
pdk validate
```

## Unit tests
For unit testing we use [RSpec]. All classes, defined resource types and functions should have appropriate unit tests.

Run unit tests:
```
cd puppet-icingaweb2
pdk test unit
```

Or dedicated tests:
```
pdk test unit --tests=spec/classes/vspheredb_spec.rb,spec/classes/vspeheredb_service_spec.rb
```

## Acceptance tests
With integration tests this module is tested on multiple platforms to check the complete installation process. We define
these tests with [ServerSpec] and run them on VMs by using [Beaker].

Run all tests:
```
pdk bundle exec rake beaker
```

Run a single test:
```
cd puppet-icingaweb2
pdk bundle exec rake beaker:ubuntu-server-1604-x64
```

Don't destroy VM after tests:
```
export BEAKER_destroy=no
pdk bundle exec rake beaker:ubuntu-server-1604-x64
```

### Run tests
All available ServerSpec tests are listed in the `spec/acceptance/` directory.

List all available tasks/platforms:
```
cd puppet-icingaweb2
pdk exec rake --task
```

[puppet-lint]: http://puppet-lint.com/
[RSpec]: http://rspec-puppet.com/
[Serverspec]: http://serverspec.org/
[Beaker]: https://github.com/puppetlabs/beaker
