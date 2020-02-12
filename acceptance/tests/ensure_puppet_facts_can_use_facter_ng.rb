test_name 'Ensure puppet facts can use facter-ng' do

  require 'puppet/acceptance/common_utils'

  teardown do
    on agent, puppet('config set facterng false')
  end

  agents.each do |agent|
    step "test puppet facts with facter-ng'" do
      on agent, puppet('config set facterng true')
      on agent, puppet('facts'), :acceptable_exit_codes => [0] do
        facter_major_version = JSON.parse(stdout)["values"]["facterversion"]
        assert_match(/4.[0-9]+.[0-9]+/, facter_major_version, "puppet failed to change cfacter to facter-ng")
      end
    end
  end
end

