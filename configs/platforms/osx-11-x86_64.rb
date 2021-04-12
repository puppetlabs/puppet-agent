platform 'osx-11-x86_64' do |plat|
  plat.servicetype 'launchd'
  plat.servicedir '/Library/LaunchDaemons'
  plat.codename "bigsur"
  plat.provision_with 'export HOMEBREW_NO_EMOJI=true'
  plat.provision_with 'export HOMEBREW_VERBOSE=true'
  plat.provision_with 'sudo dscl . -create /Users/test'
  plat.provision_with 'sudo dscl . -create /Users/test UserShell /bin/bash'
  plat.provision_with 'sudo dscl . -create /Users/test UniqueID 1001'
  plat.provision_with 'sudo dscl . -create /Users/test PrimaryGroupID 1000'
  plat.provision_with 'sudo dscl . -create /Users/test NFSHomeDirectory /Users/test'
  plat.provision_with 'sudo dscl . -passwd /Users/test password'
  plat.provision_with 'sudo dscl . -merge /Groups/admin GroupMembership test'
  plat.provision_with 'echo "test ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/username'
  plat.provision_with 'mkdir -p /etc/homebrew'
  plat.provision_with 'cd /etc/homebrew'
  plat.provision_with 'su test -c \'echo | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"\''
  plat.provision_with 'sudo chown -R test:admin /Users/test/'
  plat.vmpooler_template 'macos-112-x86_64'
  plat.output_dir File.join('apple', '11', 'puppet7', 'x86_64')
end