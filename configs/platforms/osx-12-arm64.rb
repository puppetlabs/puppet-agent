platform 'osx-12-arm64' do |plat|
    plat.servicetype 'launchd'
    plat.servicedir '/Library/LaunchDaemons'
    plat.codename 'monterey'

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
    plat.provision_with 'sudo chown -R test:admin /Users/test/Library/'

    packages = %w[cmake pkg-config yaml-cpp]

    plat.provision_with "su test -c '/usr/local/bin/brew install #{packages.join(' ')}'"

    plat.vmpooler_template 'macos-12-x86_64'
    plat.cross_compiled true
    plat.output_dir File.join('apple', '12', 'PC1', 'arm64')
  end
