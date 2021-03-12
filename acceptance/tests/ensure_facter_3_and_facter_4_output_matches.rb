test_name 'Ensure Facter 3 and Facter 4 outputs match' do
  require 'puppet/acceptance/common_utils'
  require 'puppet/acceptance/fact_dif'

  confine :except, :platform => /el-5-x86_64|aix/

  EXCLUDE_LIST = %w[ facterversion
    load_averages\..*
    processors\.speed
    swapfree swapfree_mb
    memoryfree memoryfree_mb
    memory\.swap\.available_bytes memory\.swap\.used_bytes
    memory\.swap\.available memory\.swap\.capacity memory\.swap\.used
    memory\.system\.available_bytes memory\.system\.used_bytes
    memory\.system\.available memory\.system\.capacity memory\.system\.used
    mountpoints\..*\.available* mountpoints\..*\.capacity mountpoints\..*\.used*
    sp_uptime system_profiler\.uptime
    uptime uptime_days uptime_hours uptime_seconds
    system_uptime\.uptime system_uptime\.days system_uptime\.hours system_uptime\.seconds
  ]

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
