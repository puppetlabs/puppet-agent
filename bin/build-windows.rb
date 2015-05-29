require 'yaml'
require 'json'
require 'fileutils'


# BUILD_TARGET passed through the pipeline
build_target         = ENV['BUILD_TARGET']
# The architecture of facter/the installer we are going to build
if build_target && /win\-(?<build_arch>x86|x64)/ =~ build_target
  ARCH               = build_arch
else
  ARCH               = ENV['ARCH'] || 'x64'
end

# The version of this build
AGENT_VERSION_STRING = ENV['AGENT_VERSION_STRING'] || %x{git describe --tags}.chomp.gsub('-', '.')

# Whether or not we are going to build boost and yaml-cpp or copy them from existing builds
# If `TRUE`, this will build boost and yaml-cpp according to the specifications in
# git://github.com/puppetlabs/facter/master/contrib/facter.ps1
# If `FALSE`, this will download and unpack prebuilt boost and yaml-cpp arcives.
BUILD_SOURCE         = ENV['BUILD_SOURCE'] || '0'

# Parsed information that we need to specify in order to know where to find different built facter bits
# and correctly pass information to the facter build script
script_arch          = "#{ARCH =='x64' ? '64' : '32'}"

# The refs we will use when building the MSI
PUPPET       = JSON.parse(File.read('configs/components/puppet.json'))
FACTER       = JSON.parse(File.read('configs/components/facter.json'))
HIERA        = JSON.parse(File.read('configs/components/hiera.json'))
MCO          = JSON.parse(File.read('configs/components/marionette-collective.json'))
WINDOWS      = JSON.parse(File.read('configs/components/windows_puppet.json'))
WINDOWS_RUBY = JSON.parse(File.read('configs/components/windows_ruby.json'))

ssh_key = ENV['VANAGON_SSH_KEY'] ? "-i #{ENV['VANAGON_SSH_KEY']}" : ''

#chocolatey versions
CHOCO_WIX35_VERSION = '3.5.2519.20130612'

# Retrieve a vm
vm_type = 'win-2012-x86_64'
curl_output=`curl -d --url http://vmpooler.delivery.puppetlabs.net/vm/#{vm_type}`
host_json = JSON.parse(curl_output)
hostname = host_json[vm_type]['hostname'] + '.' + host_json['domain']
puts "Acquired #{vm_type} VM from pooler at #{hostname}"

# Set up the environment so I don't keep crying
ssh_command = "ssh #{ssh_key} -tt -o StrictHostKeyChecking=no Administrator@#{hostname}"
ssh_env = "export PATH=\'/cygdrive/c/Program Files (x86)/Git/cmd:/cygdrive/c/tools/ruby21/bin:/cygdrive/c/ProgramData/chocolatey/bin:/cygdrive/c/Program Files (x86)/Windows Installer XML v3.5/bin:/usr/local/bin:/usr/bin:/cygdrive/c/Windows/system32:/cygdrive/c/Windows:/cygdrive/c/Windows/System32/Wbem:/cygdrive/c/Windows/System32/WindowsPowerShell/v1.0:/bin\'"

result = Kernel.system("#{ssh_command} \"echo \\\"#{ssh_env}\\\" >> ~/.bash_profile\"")
fail "Unable to connect to the host. Is is possible that you aren't on VPN or connected to the internal PL network?" unless result


### Build Facter
#
#

Kernel.system("#{ssh_command} 'source .bash_profile ; echo $PATH'")

# Download and execute the facter build script
# this script lives in the puppetlabs/facter repo
facter_build_script = ENV['FACTER_BUILD_SCRIPT'] ||
  "https://raw.githubusercontent.com/puppetlabs/facter/#{FACTER['ref']}/contrib/facter.ps1"
result = Kernel.system("#{ssh_command} \"curl -O #{facter_build_script} && powershell.exe -NoProfile -ExecutionPolicy Unrestricted -InputFormat None -Command ./facter.ps1 -arch #{script_arch} -buildSource #{BUILD_SOURCE} -facterRef #{FACTER['ref']} -facterFork #{FACTER['url']}\"")
fail "It looks like the facter build script #{facter_build_script} failed for some reason. I would suggest ssh'ing into the box and poking around" unless result

# Move all necessary dll's into facter bindir
Kernel.system("#{ssh_command} \"cp /cygdrive/c/tools/mingw#{script_arch}/bin/libgcc_s_#{ARCH == 'x64' ? 'seh' : 'sjlj'}-1.dll /cygdrive/c/tools/mingw#{script_arch}/bin/libstdc++-6.dll /cygdrive/c/tools/mingw#{script_arch}/bin/libwinpthread-1.dll /home/Administrator/facter/release/bin/\"")

# Format everything to prepare to archive it
Kernel.system("#{ssh_command} \"source .bash_profile ; mkdir -p /home/Administrator/archive/lib ; cp -r /home/Administrator/facter/release/bin /home/Administrator/facter/lib/inc /home/Administrator/archive/ ; cp /home/Administrator/facter/release/lib/facter.rb /home/Administrator/archive/lib/ \"")

# Zip up the built archives
Kernel.system("#{ssh_command} \"source .bash_profile ; 7za.exe a -r -tzip facter.zip 'C:\\cygwin64\\home\\Administrator\\archive\\*'\"")


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
    'mcollective' => {
      :ref  => MCO['ref'],
      :repo => MCO['url']
    },
    'sys' => {
      :ref  => WINDOWS_RUBY['ref'][ARCH],
      :repo => WINDOWS_RUBY['url']
    },
  }
}
File.open("winconfig.yaml", 'w') { |f| f.write(YAML.dump(CONFIG)) }

# Install Wix35 with chocolatey
wix_install = "choco install -y Wix35 -source https://www.myget.org/F/puppetlabs -version #{CHOCO_WIX35_VERSION}"
Kernel.system("#{ssh_command} \"source .bash_profile ; if (! #{wix_install}); then #{wix_install}; fi\"")

# Clone puppet_for_the_win
result = Kernel.system("#{ssh_command} \"source .bash_profile ; git clone #{WINDOWS['url']} puppet_for_the_win; cd puppet_for_the_win && git checkout #{WINDOWS['ref']}\"")
fail "It seems there were some issues cloning the puppet_for_the_win repo" unless result

# Send the config file over so we know what to build with
Kernel.system("scp #{ssh_key} winconfig.yaml Administrator@#{hostname}:/home/Administrator/puppet_for_the_win/")

# Build the MSI with automation in puppet_for_the_win
result = Kernel.system("#{ssh_command} \"source .bash_profile ; cd /home/Administrator/puppet_for_the_win ; AGENT_VERSION_STRING=#{AGENT_VERSION_STRING} ARCH=#{ARCH} c:/tools/ruby21/bin/rake clobber windows:build config=winconfig.yaml\"")
fail "It seems there were some issues building the puppet-agent msi" unless result

# Fetch back the built installer
FileUtils.mkdir_p("output/windows")
msi_file = "puppet-agent-#{AGENT_VERSION_STRING}-#{ARCH}.msi"
Kernel.system("scp #{ssh_key} Administrator@#{hostname}:/home/Administrator/puppet_for_the_win/pkg/#{msi_file} output/windows/")

# delete a vm only if we successfully brought back the msi
msi_path = "output/windows/#{msi_file}"
if File.exists?(msi_path)
  FileUtils.ln("./#{msi_path}", "output/windows/puppet-agent-#{ARCH}.msi")
  Kernel.system("curl -X DELETE --url \"http://vmpooler.delivery.puppetlabs.net/vm/#{hostname}\"")
  FileUtils.rm 'winconfig.yaml'
end
