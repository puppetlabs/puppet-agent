require 'puppet_docker_tools/spec_helper'

CURRENT_DIRECTORY = File.dirname(File.dirname(__FILE__))

describe 'Dockerfile' do
  include_context 'with a docker image'
  include_context 'with a docker container' do
    def docker_run_options
      "--entrypoint /bin/bash"
    end
  end

  describe 'the puppet6 repo is installed' do
    it_should_behave_like 'a running container', 'ls /etc/yum.repos.d/puppet6.repo', 0
  end

  describe 'puppet-agent is installed' do
    it_should_behave_like 'a running container', 'rpm -q puppet-agent', 0
  end

  describe 'has /opt/puppetlabs/bin/puppet' do
    it_should_behave_like 'a running container', 'stat -L /opt/puppetlabs/bin/puppet', 0, 'Access: \(0755\/\-rwxr\-xr\-x\)'
  end

  describe 'Dockerfile#running' do
    it_should_behave_like 'a running container', 'puppet help', 0
  end
end
