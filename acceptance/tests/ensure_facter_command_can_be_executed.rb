test_name 'Ensure facter command can be executed' do

  require 'puppet/acceptance/common_utils'

  facter =  agent['platform'] =~ /win/ ? 'cmd /c facter' : 'facter'

  agents.each do |agent|
    step "test facter command" do
      on agent, "#{facter} --version", :acceptable_exit_codes => [0]
    end
  end
end
