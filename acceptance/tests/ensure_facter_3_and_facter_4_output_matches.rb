test_name 'Ensure Facter 3 and Facter 4 outputs match' do
  require 'puppet/acceptance/common_utils'
  require 'puppet/acceptance/fact_dif'

  EXCLUDE_LIST = %w[os\.selinux\.enabled networking\.mtu fips_enabled mtu_lo mtu_ens192 selinux is_virtual
      load_averages\.1m load_averages\.5m load_averages\.15m mountpoints\./dev\.available_bytes
      system_uptime\.seconds system_uptime\.days system_uptime\.hours uptime_seconds uptime_days uptime_hours
      identity\.privileged identity\.gid identity\.uid processors\.physicalcount processors\.count physicalprocessorcount
      processorcount  memorysize_mb
      memoryfree_mb swapsize_mb swapfree_mb clientnoop
      memoryfree system_uptime\.uptime uptime facterversion lsbmajdistrelease blockdevices
      filesystems hypervisors\.vmware\.version sshfp_ecdsa sshfp_rsa sshfp_ed25519 sshfp_dsa
      blockdevice_.*_vendor blockdevice_.*_model blockdevice_.*_size mountpoints\..* partitions\..* operatingsystemrelease
      os\.release\.full mtu_.* networking\.interfaces\..* scope6 disks\..* hypervisors\.lpar\.partition_number.*
      interfaces.* memory\..*
      processors\.speed serialnumber sshdsakey sshrsakey swapfree hypervisors\.xen\.privileged os\.release\.minor
      boardassettag dmi\.board\.asset_tag boardassettag dmi\.board\.asset_tag lsbdistrelease lsbminordistrelease
      processor.* processors\.models\..* processors\.speed bios_release_date bios_vendor bios_version chassisassettag
      chassistype dmi\..* hypervisors\.zone\..* manufacturer productname virtual zones os\.distro\.description
      kernelmajversion uuid sshed25519key]

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
