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

    step "test puppet facts with facter-ng has all the dependencies installed" do
      on agent, puppet('config set facterng true')
      on agent, puppet('facts --debug'), :acceptable_exit_codes => [0] do
        if agent['platform'] =~ /win/
          # exclude augeas as it is not provided on Windows
          unresolved_fact = stdout.match(/(resolving fact (?!augeas).+\, but)/)
        else
          unresolved_fact = stdout.match(/(resolving fact .+\, but)/)
        end

        assert_nil(unresolved_fact, "missing dependency for facter-ng from: #{unresolved_fact.inspect}")
      end
    end

    step "test that stderr is empty on puppet facts with facter-ng'" do
      on agent, puppet('config set facterng true')
      on agent, puppet('facts'), :acceptable_exit_codes => [0] do
        assert_empty(stderr, "Expected `puppet facts` stderr to be empty")
      end
    end
  end
end

