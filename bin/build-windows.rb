require 'yaml'
require 'json'
require 'fileutils'
require 'tmpdir'

SCRIPT_ROOT = File.expand_path(File.dirname(__FILE__))

# BUILD_TARGET passed through the pipeline
build_target = ENV['BUILD_TARGET']
# The architecture of facter/the installer we are going to build
if build_target && /win\-(?<build_arch>x86|x64)/ =~ build_target
  ARCH = build_arch
else
  ARCH = ENV['ARCH'] || 'x64'
end

# The version of this build
AGENT_VERSION_STRING = ENV['AGENT_VERSION_STRING'] || `git describe --tags`.chomp.tr('-', '.')

# Whether or not we are going to build boost and yaml-cpp or copy them from existing builds
# If `TRUE`, this will build boost and yaml-cpp according to the specifications in
# git://github.com/puppetlabs/facter/master/contrib/facter.ps1
# If `FALSE`, this will download and unpack prebuilt boost and yaml-cpp arcives.
BUILD_SOURCE         = ENV['BUILD_SOURCE'] || '0'

# Parsed information that we need to specify in order to know where to find different built facter bits
# and correctly pass information to the facter build script
script_arch          = "#{ARCH == 'x64' ? '64' : '32'}"

# The refs we will use when building the MSI
PUPPET       = JSON.parse(File.read('configs/components/puppet.json'))
FACTER       = JSON.parse(File.read('configs/components/facter.json'))
CPPPCPCLIENT = JSON.parse(File.read('configs/components/cpp-pcp-client.json'))
PXPAGENT     = JSON.parse(File.read('configs/components/pxp-agent.json'))
HIERA        = JSON.parse(File.read('configs/components/hiera.json'))
MCO          = JSON.parse(File.read('configs/components/marionette-collective.json'))
NSSM         = JSON.parse(File.read('configs/components/nssm.json'))
WINDOWS      = JSON.parse(File.read('configs/components/windows_puppet.json'))
WINDOWS_RUBY = JSON.parse(File.read('configs/components/windows_ruby.json'))

ssh_key = ENV['VANAGON_SSH_KEY'] ? "-i #{ENV['VANAGON_SSH_KEY']}" : ''

# Retrieve a vm
vm_type = 'win-2012r2-x86_64'
auth_token = ENV['VMPOOL_TOKEN'] || ''
curl_output = `curl --data --url http://vmpooler.delivery.puppetlabs.net/vm/#{vm_type} -H X-AUTH-TOKEN:#{auth_token}`
host_json = JSON.parse(curl_output)
hostname = host_json[vm_type]['hostname'] + '.' + host_json['domain']
puts "Acquired #{vm_type} VM from pooler at #{hostname}"

# uses above variables ssh_key and hostname
def clone_and_rynsc_private_repo(fork, ref, hostname, ssh_key)
  Dir.mktmpdir do |tmp_dir|
    name = fork.split('/').last.split('.').first
    result = Kernel.system("set -vx; cd #{tmp_dir} && git clone #{fork} && cd #{name} && git checkout #{ref} && git submodule update --init --recursive")
    fail "It seems there were some issues cloning the repo: #{fork}\n#{result}" unless $?.success?

    # rsync to windows requires protocol=29 and ssh command w/o -tt option to work.
    rsync_command = "rsync -e 'ssh #{ssh_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' -Hl --protocol 29 --verbose --recursive --no-perms --no-owner --no-group"

    # Push the repos over to the build pooler machine.
    cmd = "#{rsync_command} #{tmp_dir}/#{name} 'Administrator@#{hostname}:~/'"
    puts cmd
    result = Kernel.system(cmd)
    fail "It seems there were some issues rsyncing the repo: #{fork}\n#{result}" unless $?.success?
  end
end

# Set up the environment so I don't keep crying
ssh_command = "ssh #{ssh_key} -tt -o StrictHostKeyChecking=no Administrator@#{hostname}"
ssh_env = "export PATH=\'/cygdrive/c/Program Files (x86)/Git/cmd:/cygdrive/c/tools/ruby21/bin:/cygdrive/c/ProgramData/chocolatey/bin:/cygdrive/c/Program Files (x86)/Windows Installer XML v3.5/bin:/usr/local/bin:/usr/bin:/cygdrive/c/Windows/system32:/cygdrive/c/Windows:/cygdrive/c/Windows/System32/Wbem:/cygdrive/c/Windows/System32/WindowsPowerShell/v1.0:/bin\'"

result = Kernel.system("set -vx;#{ssh_command} \"echo \\\"#{ssh_env}\\\" >> ~/.bash_profile\"")
fail "Unable to connect to the host. Is is possible that you aren't on VPN or connected to the internal PL network?" unless result


### Build Facter
#
#

Kernel.system("set -vx;#{ssh_command} 'source .bash_profile ; echo $PATH'")

Kernel.system("scp #{File.join(SCRIPT_ROOT, 'windows-env.ps1')} Administrator@#{hostname}:/home/Administrator/")
fail "Copying windows-env.ps1 to #{hostname} failed" unless $?.success?
Kernel.system("scp #{File.join(SCRIPT_ROOT, 'windows-toolset.ps1')} Administrator@#{hostname}:/home/Administrator/")
fail "Copying windows-toolset.ps1 to #{hostname} failed" unless $?.success?

# Ready the Windows Build Environment, followed by the facter and pxp-agent build scripts

puts "Build-Windows.rb... Setting up windows toolset - windows-toolset.ps1"
result = Kernel.system("#{ssh_command} \"powershell.exe -NoProfile -ExecutionPolicy Unrestricted -InputFormat None -Command ./windows-toolset.ps1 -arch #{script_arch} -buildSource #{BUILD_SOURCE}\"")
fail "It looks like the Windows-toolset build script failed for some reason. I would suggest ssh'ing into the box and poking around" unless result
puts "Build-Windows.rb... Windows Setup Completed!!"

puts "Build-Windows.rb... building facter"
Kernel.system("scp #{File.join(SCRIPT_ROOT, 'build-facter.ps1')} Administrator@#{hostname}:/home/Administrator/")
fail "Copying build-facter.ps1 to #{hostname} failed" unless $?.success?
result = Kernel.system("set -vx;#{ssh_command} \"powershell.exe -NoProfile -ExecutionPolicy Unrestricted -InputFormat None -Command ./build-facter.ps1 -arch #{script_arch} -buildSource #{BUILD_SOURCE} -facterRef #{FACTER['ref']} -facterFork #{FACTER['url']}\"")
fail "It looks like the facter build script build-facter.ps1 failed for some reason. I would suggest ssh'ing into the box and poking around:\n#{result}" unless result
puts "Build-Windows.rb... facter build Completed!!"

puts "Build-Windows.rb... building cpp-pcp-client"
Kernel.system("scp #{File.join(SCRIPT_ROOT, 'build-cpp-pcp-client.ps1')} Administrator@#{hostname}:/home/Administrator/")
fail "Copying build-cpp-pcp-client.ps1 to #{hostname} failed" unless $?.success?
clone_and_rynsc_private_repo(CPPPCPCLIENT['url'], CPPPCPCLIENT['ref'], hostname, ssh_key)
result = Kernel.system("#{ssh_command} \"powershell.exe -NoProfile -ExecutionPolicy Unrestricted -InputFormat None -Command ./build-cpp-pcp-client.ps1 -arch #{script_arch}\"")
fail "It looks like the cpp-pcp-client build script failed for some reason. I would suggest ssh'ing into the box and poking around" unless result

puts "Build-Windows.rb... building pxp-agent"
Kernel.system("scp #{File.join(SCRIPT_ROOT, 'build-pxp-agent.ps1')} Administrator@#{hostname}:/home/Administrator/")
fail "Copying build-pxp-agent.ps1 to #{hostname} failed" unless $?.success?
clone_and_rynsc_private_repo(PXPAGENT['url'], PXPAGENT['ref'], hostname, ssh_key)
result = Kernel.system("#{ssh_command} \"powershell.exe -NoProfile -ExecutionPolicy Unrestricted -InputFormat None -Command ./build-pxp-agent.ps1 -arch #{script_arch}\"")
fail "It looks like the pxp-agent build script failed for some reason. I would suggest ssh'ing into the box and poking around" unless result

# Move all necessary dll's into facter bindir
Kernel.system("set -vx;#{ssh_command} \"cp /cygdrive/c/tools/mingw#{script_arch}/bin/libgcc_s_#{ARCH == 'x64' ? 'seh' : 'sjlj'}-1.dll /cygdrive/c/tools/mingw#{script_arch}/bin/libstdc++-6.dll /cygdrive/c/tools/mingw#{script_arch}/bin/libwinpthread-1.dll /home/Administrator/facter/release/bin/\"")
fail "Copying compiler DLLs to build directory failed" unless $?.success?
# Repeat for pxp-agent (CTH-357)
Kernel.system("set -vx;#{ssh_command} \"cp /cygdrive/c/tools/mingw#{script_arch}/bin/libgcc_s_#{ARCH == 'x64' ? 'seh' : 'sjlj'}-1.dll /cygdrive/c/tools/mingw#{script_arch}/bin/libstdc++-6.dll /cygdrive/c/tools/mingw#{script_arch}/bin/libwinpthread-1.dll /home/Administrator/pxp-agent/release/bin/\"")
fail "Copying compiler DLLs to build directory failed" unless $?.success?

archive_dest = "/home/Administrator/archive"
facter_zipname = "facter"
pxp_zipname = "pxp-agent"
# Format everything to prepare to archive it
Kernel.system("set -vx;#{ssh_command} \"source .bash_profile ; mkdir -p #{archive_dest}/#{facter_zipname}/lib ; cp -r /home/Administrator/facter/release/bin /home/Administrator/facter/lib/inc #{archive_dest}/#{facter_zipname} ; cp /home/Administrator/facter/release/lib/facter.rb #{archive_dest}/#{facter_zipname}/lib \"")
fail "Copying source files for packaging failed" unless $?.success?
# repeat for pxp-agent
Kernel.system("set -vx;#{ssh_command} \"source .bash_profile ; mkdir -p #{archive_dest}/#{pxp_zipname}/pxp-modules ; cp -r /home/Administrator/cpp-pcp-client/release/bin /home/Administrator/cpp-pcp-client/lib/inc #{archive_dest}/#{pxp_zipname} ; cp -r /home/Administrator/pxp-agent/release/bin /home/Administrator/pxp-agent/lib/inc #{archive_dest}/#{pxp_zipname}; cp -r /home/Administrator/pxp-agent/modules/pxp-module-puppet #{archive_dest}/#{pxp_zipname}/pxp-modules \"")
fail "Copying source files for packaging failed" unless $?.success?

# Zip up the built archives
Kernel.system("set -vx;#{ssh_command} \"source .bash_profile ; 7za.exe a -r -tzip #{facter_zipname}.zip 'C:\\cygwin64\\home\\Administrator\\archive\\#{facter_zipname}\\*'\"")
Kernel.system("set -vx;#{ssh_command} \"source .bash_profile ; 7za.exe a -r -tzip #{pxp_zipname}.zip    'C:\\cygwin64\\home\\Administrator\\archive\\#{pxp_zipname}\\*'\"")

### Build puppet-agent.msi


CONFIG = {
  :repos => {
    'puppet' => {
      :ref  => PUPPET['ref'],
      :repo => PUPPET['url']
    },
    'hiera' => {
      :ref  => HIERA['ref'],
      :repo => HIERA['url']
    },
    'facter' => {
      :archive => 'facter.zip',
      :path    => 'file:///home/Administrator'
    },
    'pxp-agent' => {
      :archive => 'pxp-agent.zip',
      :path    => 'file:///home/Administrator'
    },
    'mcollective' => {
      :ref  => MCO['ref'],
      :repo => MCO['url']
    },
    'sys' => {
      :ref  => WINDOWS_RUBY['ref'][ARCH],
      :repo => WINDOWS_RUBY['url']
    },
    'nssm' => {
      :archive => NSSM['url'].rpartition('/').last,
      :path    => NSSM['url'].rpartition('/').first + '/'
    },
  }
}
File.open("winconfig.yaml", 'w') { |f| f.write(YAML.dump(CONFIG)) }

# Clone puppet_for_the_win
result = Kernel.system("set -vx;#{ssh_command} \"source .bash_profile ; git clone #{WINDOWS['url']} puppet_for_the_win; cd puppet_for_the_win && git checkout #{WINDOWS['ref']}\"")
fail "It seems there were some issues cloning the puppet_for_the_win repo" unless result

# Send the config file over so we know what to build with
Kernel.system("set -vx;scp #{ssh_key} winconfig.yaml Administrator@#{hostname}:/home/Administrator/puppet_for_the_win/")

# Build the MSI with automation in puppet_for_the_win
result = Kernel.system("set -vx;#{ssh_command} \"source .bash_profile ; cd /home/Administrator/puppet_for_the_win ; AGENT_VERSION_STRING=#{AGENT_VERSION_STRING} ARCH=#{ARCH} c:/tools/ruby21/bin/rake clobber windows:build config=winconfig.yaml\"")
fail "It seems there were some issues building the puppet-agent msi" unless result

# Fetch back the built installer
FileUtils.mkdir_p("output/windows")
msi_file = "puppet-agent-#{AGENT_VERSION_STRING}-#{ARCH}.msi"
Kernel.system("set -vx;scp #{ssh_key} Administrator@#{hostname}:/home/Administrator/puppet_for_the_win/pkg/#{msi_file} output/windows/")

# delete a vm only if we successfully brought back the msi
msi_path = "output/windows/#{msi_file}"
if File.exists?(msi_path)
  FileUtils.ln("./#{msi_path}", "output/windows/puppet-agent-#{ARCH}.msi")
  Kernel.system("set -vx;curl -X DELETE --url \"http://vmpooler.delivery.puppetlabs.net/vm/#{hostname}\"")
  FileUtils.rm 'winconfig.yaml'
end
