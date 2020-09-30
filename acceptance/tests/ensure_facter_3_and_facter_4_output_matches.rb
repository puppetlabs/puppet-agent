test_name 'Ensure Facter 3 and Facter 4 outputs match' do
  require 'puppet/acceptance/common_utils'
  require 'puppet/acceptance/fact_dif'

  confine :except, :platform => /el-5-x86_64|el-8-aarch64/

  EXCLUDE_LIST = %w[ fips_enabled facterversion identity\.gid identity\.privileged identity\.uid
                    load_averages\.15m load_averages\.1m load_averages\.5m memory\.swap\.available_bytes
                    memory\.swap\.capacity memory\.swap\.total_bytes memory\.swap\.used_bytes memory\.swap\.available
                    memory\.system\.available memory\.system\.available_bytes memory\.system\.capacity memory\.swap\.used
                    memory\.system\.total_bytes memory\.system\.used memory\.system\.used_bytes memoryfree memoryfree_mb
                    memorysize_mb mountpoints\..* mtu_.* networking\.interfaces\..*\.mtu networking\.mtu
                    os\.selinux\.enabled partitions\..*\.filesystem partitions\..*\.size_bytes partitions\..*\.mount
                    partitions\..*\.uuid physicalprocessorcount processorcount processors\.count
                    processors\.physicalcount selinux swapfree_mb swapsize_mb system_uptime\.days system_uptime\.hours
                    system_uptime\.seconds uptime_days uptime_hours uptime_seconds clientnoop swapfree
                    disks\..*\.size_bytes hypervisors\.lpar\.partition_number mountpoints\..*\.capacity
                    processors\.speed serialnumber hypervisors\.xen\.privileged os\.release.\minor
                    operatingsystemrelease os\.release\.full os\.distro\.description filesystems
                    sp_uptime system_profiler\.uptime os\.release\.minor
                    hypervisors\.zone\..* system_uptime\.uptime uptime hypervisors\.ldom\..* ldom_.*
                    boardassettag dmi\.board\.asset_tag is_virtual kernelmajversion lsbmajdistrelease]

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
