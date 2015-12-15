platform "osx-10.11-x86_64" do |plat|
  plat.servicetype 'launchd'
  plat.servicedir '/Library/LaunchDaemons'
  plat.codename "elcapitan"

  plat.provision_with 'cd /usr/local; git clone https://github.com/Homebrew/homebrew.git .; /usr/local/bin/brew install pkgconfig'
  plat.install_build_dependencies_with "PATH=$PATH:/usr/local/bin brew install "
  plat.vmpooler_template "osx-1011-x86_64"
end
