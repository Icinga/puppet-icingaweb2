require 'spec_helper'

describe('icingaweb2::module::cube', type: :class) do
  let(:pre_condition) do
    [
      "class { 'icingaweb2': db_type => 'mysql', db_password => 'secret' }",
    ]
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      context "#{os} with git_revision 'v1.0.0'" do
        let(:params) { { git_revision: 'v1.0.0' } }

        it {
          is_expected.to contain_icingaweb2__module('cube')
            .with_install_method('git')
            .with_git_revision('v1.0.0')
        }
      end
    end
  end
end
