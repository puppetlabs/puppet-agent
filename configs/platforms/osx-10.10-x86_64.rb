platform "osx-10.10-x86_64" do |plat|
  plat.servicetype 'launchd'
  plat.servicedir '/Library/LaunchDaemons'
  plat.codename "yosemite"

  plat.provision_with 'softwareupdate -i "Command Line Tools (OS X 10.10) for Xcode-7.1"'
  plat.provision_with 'mkdir /usr/local; cd /usr/local; git clone https://github.com/Homebrew/homebrew.git .; git checkout ab475 -- Library/Formula/boost.rb; /usr/local/bin/brew install pkgconfig'
  plat.install_build_dependencies_with "PATH=$PATH:/usr/local/bin brew install "
  plat.vmpooler_template "osx-1010-x86_64"
end
