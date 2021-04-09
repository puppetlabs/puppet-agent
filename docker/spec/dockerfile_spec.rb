include Pupperware::SpecHelpers

# unifies volume naming
ENV['COMPOSE_PROJECT_NAME'] ||= 'puppet-agent'
Pupperware::SpecHelpers.load_compose_services = 'puppet'

RSpec.configure do |c|
  c.before(:suite) do
    ENV['PUPPET_AGENT_IMAGE'] = require_test_image
    pull_images(['agent_apply', 'agent_facter', 'agent-run'])
    teardown_cluster
    docker_compose_up(preload_certs: false)
  end

  c.after(:suite) do
    emit_logs
    teardown_cluster
  end
end

describe 'puppet-agent container' do
  {
    'agent-apply': 'be able to run a puppet apply',
    'agent-facter': 'be able to run facter',
    'agent-run': 'be able to run against a server'
  }.each do |container, op|
    it "should #{op}" do
      container = get_service_container(container)
      wait_on_container_exit(container)
      expect(get_container_exit_code(container)).to eq(0)
      emit_log(container)
    end
  end
end
