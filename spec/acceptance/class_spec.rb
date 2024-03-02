require 'spec_helper_acceptance'

describe 'icingaweb2 class:' do
  describe 'icingaweb2 with defaults' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-MANIFEST
          case $facts['os']['family'] {
            'redhat': {
              if $facts['os']['name'] == 'centos' and Integer($facts['os']['release']['major']) < 8 {
                package { 'centos-release-scl': }

                $php_globals    = {
                  php_version => 'rh-php71',
                  rhscl_mode  => 'rhscl',
                }
              } else {
                $php_globals = {}
              }

              $php_extensions = {
                mbstring => { ini_prefix => '20-' },
                json     => { ini_prefix => '20-' },
                ldap     => { ini_prefix => '20-' },
                gd       => { ini_prefix => '20-' },
                xml      => { ini_prefix => '20-' },
                intl     => { ini_prefix => '20-' },
                mysqlnd  => { ini_prefix => '20-' },
                pgsql    => { ini_prefix => '20-' },
              }
              $web_conf_user = 'apache'
            } # RedHat

            'debian': {
              $php_globals    = {}
              $php_extensions = {
                mbstring => {},
                json     => {},
                ldap     => {},
                gd       => {},
                xml      => {},
                intl     => {},
                mysql    => {},
                pgsql    => {},
              }
              $web_conf_user = 'www-data'
            } # Debian

            default: {
              fail("'Your operatingsystem ${::operatingsystem} is not supported.'")
            }
          }

          #
          # PHP
          #
          class { '::php::globals':
            * => $php_globals,
          }

          class { '::php':
            ensure        => installed,
            manage_repos  => false,
            apache_config => false,
            fpm           => true,
            extensions    => $php_extensions,
            dev           => false,
            composer      => false,
            pear          => false,
            phpunit       => false,
            require       => Class['::php::globals'],
          }

          #
          # Apache
          #
          class { '::apache':
            default_mods  => false,
            default_vhost => false,
            mpm_module    => 'worker',
          }

          apache::listen { '80': }

          include ::apache::mod::alias
          include ::apache::mod::status
          include ::apache::mod::dir
          include ::apache::mod::env
          include ::apache::mod::rewrite
          include ::apache::mod::proxy
          include ::apache::mod::proxy_fcgi

          apache::custom_config { 'icingaweb2':
            ensure        => present,
            source        => 'puppet:///modules/icingaweb2/examples/apache2/for-mod_proxy_fcgi.conf',
            verify_config => false,
            priority      => false,
          }

          #
          # Icinga Web 2
          #
          include ::mysql::server

          mysql::db { 'icingaweb2':
            user     => 'icingaweb2',
            password => 'icingaweb2',
            host     => 'localhost',
            grant    => ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'DROP', 'CREATE VIEW', 'CREATE', 'INDEX', 'EXECUTE', 'ALTER', 'REFERENCES'],
            before   => Class['icingaweb2'],
          }

          Package['icingaweb2']
            -> Class['apache']

          class { 'icingaweb2':
            manage_repos  => true,
            conf_user     => $web_conf_user,
            db_type       => 'mysql',
            db_host       => 'localhost',
            db_port       => 3306,
            db_username   => 'icingaweb2',
            db_password   => 'icingaweb2',
            import_schema => true,
          }
        MANIFEST
      end
    end

    describe package('icingaweb2') do
      it { is_expected.to be_installed }
    end

    describe file('/etc/icingaweb2/config.ini') do
      it { is_expected.to be_file }
      it { is_expected.to contain '[global]' }
      it { is_expected.to contain '[logging]' }
    end

    describe command('curl -I http://localhost/icingaweb2/') do
      its(:stdout) { is_expected.to match(%r{302 Found}) }
    end

    describe file('/etc/icingaweb2/resources.ini') do
      it { is_expected.to be_file }
      it { is_expected.to contain '[mysql-icingaweb2]' }
      it { is_expected.to contain 'type = "db"' }
      it { is_expected.to contain 'db = "mysql"' }
      it { is_expected.to contain 'host = "localhost"' }
      it { is_expected.to contain 'port = "3306"' }
      it { is_expected.to contain 'dbname = "icingaweb2"' }
      it { is_expected.to contain 'username = "icingaweb2"' }
      it { is_expected.to contain 'password = "icingaweb2"' }
    end

    describe file('/etc/icingaweb2/authentication.ini') do
      it { is_expected.to be_file }
      it { is_expected.to contain '[mysql-auth]' }
      it { is_expected.to contain 'backend = "db"' }
      it { is_expected.to contain 'resource = "mysql-icingaweb2"' }
    end

    describe file('/etc/icingaweb2/roles.ini') do
      it { is_expected.to be_file }
      it { is_expected.to contain '[default admin user]' }
      it { is_expected.to contain 'users = "icingaadmin"' }
      it { is_expected.to contain 'permissions = "*"' }
    end

    describe command('mysql -e "select name from icingaweb2.icingaweb_user"') do
      its(:stdout) { is_expected.to match(%r{icingaadmin}) }
    end
  end
end
