platform "ubuntu-14.10-i386" do |plat|
  plat.servicedir "/etc/init.d"
  plat.defaultdir "/etc/default"
  plat.servicetype "sysv"
  plat.codename "utopic"

  plat.apt_repo "http://pl-build-tools.delivery.puppetlabs.net/debian/pl-build-tools-release-utopic.deb"
  plat.provision_with "export DEBIAN_FRONTEND=noninteractive; apt-get update -qq; apt-get install -qy --no-install-recommends build-essential devscripts make quilt pkg-config debhelper fakeroot"
  plat.install_build_dependencies_with "DEBIAN_FRONTEND=noninteractive; apt-get install -qy --no-install-recommends "
  plat.vcloud_name "ubuntu-1410-i386"
end
