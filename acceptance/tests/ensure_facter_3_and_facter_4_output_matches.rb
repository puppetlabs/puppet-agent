test_name 'Ensure Facter 3 and Facter 4 outputs match' do
  require 'puppet/acceptance/common_utils'
  require 'puppet/acceptance/fact_dif'

  confine :except, :platform => 'el-5-x86_64'

  EXCLUDE_LIST = %w[]

  agents.each do |agent|
    teardown do
      step 'disable facterng feature flag' do
        on agent, puppet('config set facterng false')
      end
    end

    step 'obtain output from puppet facts running with Facter 3.x' do
      on agent, puppet('facts') do
        @facter3_output = stdout
      end
    end

    step 'enable facterng feature flag' do
      on agent, puppet('config set facterng true')
    end

    step 'obtain output from puppet facts running with Facter 4.x' do
      on agent, puppet('facts') do
        @facter4_output = stdout
      end
    end

    step 'compare Facter 3 to Facter 4 outputs' do
      fact_dif = FactDif.new(@facter3_output, @facter4_output, EXCLUDE_LIST)
      unless fact_dif.difs.empty?
        fail_test("Facter 3 and Facter 4 outputs have the fallowing differences:  #{fact_dif.difs}")
      end
    end
  end
end
