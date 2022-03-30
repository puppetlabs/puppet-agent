test_name 'Ensure Facter 3 and Facter 4 outputs match' do
  require 'puppet/acceptance/common_utils'

  confine :except, :platform => /aix/

  exclude_list = %w{mountpoints\..*
    partitions\..*\.filesystem
    partitions\..*\.size_bytes
    partitions\..*\.mount        	
    partitions\..*\.uuid
    ldom_.*                   	
    boardassettag 	
    dmi\.board\.asset_tag 	
    is_virtual 	
    kernelmajversion 	
    lsbmajdistrelease 	
    zones 	
    virtual                   	
    blockdevice_.*_vendor blockdevice_.*_size
    hypervisors.vmware.version
    os\.distro\.description  }

  agents.each do |agent|
    exclude_list += ['macosx_productversion.*', 'os.macosx.version'] if agent.platform =~ /^osx-1[1-9]/

    step 'run puppet facts diff ' do
      on agent, puppet('facts diff') do
        @diff = stdout
        
      end
    end

    step 'compare Facter 3 to Facter 4 outputs' do
      join_str = agent.platform =~ /windows/ ? '^^^|' : '|' 
      ignored_facts = exclude_list.join(join_str)
      on(agent, puppet("facts diff --exclude '#{ignored_facts}'")) do
        diff = JSON.parse(stdout)
        
        rep_diff = diff.delete_if {|key, value| value['old_value'] == nil}
        fail_test("Facter 3 and Facter 4 outputs have the following differences:  #{diff}") if rep_diff.keys.size.positive?
      end
    end
  end
end
