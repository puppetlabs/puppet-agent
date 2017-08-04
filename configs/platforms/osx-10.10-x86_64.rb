platform "osx-10.10-x86_64" do |plat|
  plat.servicetype 'launchd'
  plat.servicedir '/Library/LaunchDaemons'
  plat.codename "yosemite"

  plat.provision_with 'mkdir /usr/local; curl http://pl-build-tools.delivery.puppetlabs.net/osx/homebrew.tar.gz | tar -x --strip 1 -C /usr/local -f -'
  plat.provision_with 'ssh-keyscan github.delivery.puppetlabs.net >> ~/.ssh/known_hosts; /usr/local/bin/brew tap puppetlabs/brew-build-tools gitmirror@github.delivery.puppetlabs.net:puppetlabs-homebrew-build-tools'
  plat.provision_with '/usr/local/bin/brew tap-pin puppetlabs/brew-build-tools'
  plat.provision_with 'curl -o /usr/local/bin/osx-deps http://pl-build-tools.delivery.puppetlabs.net/osx/osx-deps; chmod 755 /usr/local/bin/osx-deps'
  plat.provision_with '/usr/local/bin/osx-deps apple-clt-7.2 pkg-config'
  plat.install_build_dependencies_with "/usr/local/bin/osx-deps "
  plat.vmpooler_template "osx-1010-x86_64"
end
