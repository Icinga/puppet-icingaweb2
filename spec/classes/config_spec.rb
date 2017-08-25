require 'spec_helper'

describe('icingaweb2::config', :type => :class) do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      context 'with default parameters' do
        let :pre_condition do
          "class { 'icingaweb2': }"
        end

        it { is_expected.to contain_icingaweb2__inisection('logging') }
        it { is_expected.to contain_icingaweb2__inisection('preferences') }
        it { is_expected.to contain_icingaweb2__inisection('logging') }
        it { is_expected.to contain_icingaweb2__inisection('global') }
        it { is_expected.to contain_icingaweb2__inisection('themes') }
      end

      context 'with import_schema => true and db_type => mysql' do
        let :pre_condition do
          "class { 'icingaweb2': import_schema => true, db_type => 'mysql'}"
        end

        it { is_expected.to contain_icingaweb2__config__resource('mysql-icingaweb2')}
        it { is_expected.to contain_icingaweb2__config__authmethod('mysql-auth')}
        it { is_expected.to contain_icingaweb2__config__role('default admin user')}
        it { is_expected.to contain_exec('import schema') }
        it { is_expected.to contain_exec('create default user') }
      end

      context 'with import_schema => true and db_type => pgsql' do
        let :pre_condition do
          "class { 'icingaweb2': import_schema => true, db_type => 'pgsql'}"
        end

        it { is_expected.to contain_icingaweb2__config__resource('pgsql-icingaweb2')}
        it { is_expected.to contain_icingaweb2__config__authmethod('pgsql-auth')}
        it { is_expected.to contain_icingaweb2__config__role('default admin user')}
        it { is_expected.to contain_exec('import schema') }
        it { is_expected.to contain_exec('create default user') }
      end

      context 'with import_schema => true and invalid db_type' do
        let :pre_condition do
          "class { 'icingaweb2': import_schema => true, db_type => 'foobar'}"
        end

        it { is_expected.to raise_error(Puppet::Error, /foobar isn't supported/) }
      end

      context 'with import_schema => false' do
        let :pre_condition do
          "class { 'icingaweb2': import_schema => false }"
        end

        it { is_expected.not_to contain_exec('import schema')}
        it { is_expected.not_to contain_exec('create default user')}
        it { is_expected.not_to contain_icingaweb2__config__role('default admin user')}
      end
    end
  end
end
