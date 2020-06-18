test_name 'Ensure puppet facts can use facter' do

  require 'puppet/acceptance/common_utils'

  agents.each do |agent|
    step 'test puppet facts with correct facter version' do
      on agent, puppet('facts'), :acceptable_exit_codes => [0] do
        facter_major_version = JSON.parse(stdout)["values"]["facterversion"]
        assert_match(/4.[0-9]+.[0-9]+/, facter_major_version, "wrong facter version")
      end
    end

    step "test puppet facts with facter has all the dependencies installed" do
      on agent, puppet('facts --debug'), :acceptable_exit_codes => [0] do
        unresolved_fact = stdout.match(/(resolving fact .+\, but)/)
        assert_nil(unresolved_fact, "missing dependency for facter from: #{unresolved_fact.inspect}")
      end
    end
  end
end

