require 'puppet_docker_tools/spec_helper'

CURRENT_DIRECTORY = File.dirname(File.dirname(__FILE__))

describe 'Dockerfile' do
  include_context 'with a docker image'

  describe package('puppet-agent') do
    it { is_expected.to be_installed }
  end

  describe file('/opt/puppetlabs/bin/puppet') do
    it { should exist }
    it { should be_executable }
  end

  describe 'Dockerfile#running' do
    it_should_behave_like 'a running container', 'help', 0
  end
end
