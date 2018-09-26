require 'puppet_docker_tools/spec_helper'

CURRENT_DIRECTORY = File.dirname(File.dirname(__FILE__))

describe 'Dockerfile' do
  include_context 'with a docker image'
  include_context 'with a docker container' do
    def docker_run_options
      "--entrypoint /bin/bash"
    end
  end

  ['puppet-agent', 'lsb-release'].each do |package_name|
    describe "has #{package_name} installed" do
      it_should_behave_like 'a running container', "dpkg -l #{package_name}", 0
    end
  end

  describe 'wget is not installed' do
    it_should_behave_like 'a running container', "dpkg -l wget", 1
  end

  describe 'has /opt/puppetlabs/bin/puppet' do
    it_should_behave_like 'a running container', 'stat -L /opt/puppetlabs/bin/puppet', 0, 'Access: \(0755\/\-rwxr\-xr\-x\)'
  end

  describe 'Dockerfile#running' do
    it_should_behave_like 'a running container', 'puppet help', 0
  end
end
