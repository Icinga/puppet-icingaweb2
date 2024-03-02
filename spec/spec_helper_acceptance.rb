# frozen_string_literal: true

require 'voxpupuli/acceptance/spec_helper_acceptance'

configure_beaker do |host|
  install_puppet_module_via_pmt_on(host, 'puppetlabs-mysql')
  install_puppet_module_via_pmt_on(host, 'puppetlabs-postgresql')
  install_puppet_module_via_pmt_on(host, 'puppetlabs-apache')
  install_puppet_module_via_pmt_on(host, 'puppet-php')
  install_puppet_module_via_pmt_on(host, 'puppetlabs-apt')
  install_puppet_module_via_pmt_on(host, 'puppet-zypprepo')
end
