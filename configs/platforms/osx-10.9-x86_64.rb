platform "osx-10.9-x86_64" do |plat|
  plat.servicetype 'launchd'
  plat.servicedir '/Library/LaunchDaemons'
  plat.codename "mavericks"

  plat.provision_with 'softwareupdate -i "Command Line Tools (OS X Mavericks)-6.2"'
  plat.provision_with 'mkdir /usr/local; cd /usr/local; git clone https://github.com/Homebrew/homebrew.git .; git checkout ab475 -- Library/Formula/boost.rb; /usr/local/bin/brew install pkgconfig'
  plat.install_build_dependencies_with "PATH=$PATH:/usr/local/bin brew install "
  plat.vmpooler_template "osx-109-x86_64"
end
