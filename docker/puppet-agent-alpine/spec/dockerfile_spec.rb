require 'puppet_docker_tools/spec_helper'

CURRENT_DIRECTORY = File.dirname(File.dirname(__FILE__))

describe 'Dockerfile' do
  include_context 'with a docker image'
  include_context 'with a docker container' do
    def docker_run_options
      "--entrypoint /bin/sh"
    end
  end

  describe 'has puppet installed' do
    it_should_behave_like 'a running container', 'gem list --installed puppet', 0
  end

  describe 'has /usr/bin/puppet' do
    it_should_behave_like 'a running container', 'stat -L /usr/local/bin/puppet', 0, 'Access: \(0755\/\-rwxr\-xr\-x\)'
  end

  describe 'Dockerfile#running' do
    it_should_behave_like 'a running container', 'puppet help', 0
  end
end
