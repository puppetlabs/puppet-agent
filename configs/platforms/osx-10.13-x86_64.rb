platform "osx-10.13-x86_64" do |plat|
  plat.servicetype 'launchd'
  plat.servicedir '/Library/LaunchDaemons'
  plat.codename "highsierra"

  plat.provision_with 'export HOMEBREW_NO_AUTO_UPDATE=true'
  plat.provision_with 'export HOMEBREW_NO_EMOJI=true'
  plat.provision_with 'export HOMEBREW_VERBOSE=true'

  plat.provision_with 'curl http://pl-build-tools.delivery.puppetlabs.net/osx/homebrew_sierra.tar.gz | tar -x --strip 1 -C /usr/local -f -'
  plat.provision_with 'curl http://pl-build-tools.delivery.puppetlabs.net/osx/patches/0001-Add-needs-cxx14.patch | patch -p0'
  plat.provision_with 'ssh-keyscan github.delivery.puppetlabs.net >> ~/.ssh/known_hosts; /usr/local/bin/brew tap puppetlabs/brew-build-tools gitmirror@github.delivery.puppetlabs.net:puppetlabs-homebrew-build-tools'
  plat.provision_with '/usr/local/bin/brew tap-pin puppetlabs/brew-build-tools'
  plat.provision_with 'curl -o /usr/local/bin/osx-deps http://pl-build-tools.delivery.puppetlabs.net/osx/osx-deps; chmod 755 /usr/local/bin/osx-deps'
  plat.provision_with '/usr/local/bin/osx-deps pkg-config'
  plat.install_build_dependencies_with "/usr/local/bin/osx-deps "
  plat.vmpooler_template "osx-1012-x86_64"
  plat.output_dir File.join("mac", "10.13", "puppet6", "x86_64")
end
