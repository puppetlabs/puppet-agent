test_name 'Ensure facter-ng command can be executed' do

  confine :to, :platform => /no-platform-yet/

  require 'puppet/acceptance/common_utils'

  facter_ng =  agent['platform'] =~ /win/ ? 'cmd /c facter-ng' : 'facter-ng'

  agents.each do |agent|
    step "test facter-ng command" do
      on agent, "#{facter_ng} --version", :acceptable_exit_codes => [0]
    end
  end
end
