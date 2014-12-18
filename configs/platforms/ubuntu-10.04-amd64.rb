platform "ubuntu-10.04-amd64" do |plat|
  plat.servicedir "/etc/init.d"
  plat.defaultdir "/etc/default"
  plat.servicetype "sysv"
  plat.codename "lucid"

  plat.provision_with "export DEBIAN_FRONTEND=noninteractive; wget http://pl-build-tools.delivery.puppetlabs.net/debian/pl-build-tools-release-lucid.deb;dpkg -i pl-build-tools-release-lucid.deb;apt-get update -qq; apt-get install -qy --no-install-recommends build-essential devscripts make quilt pkg-config debhelper fakeroot "
  plat.install_build_dependencies_with "DEBIAN_FRONTEND=noninteractive; apt-get install -qy --no-install-recommends "
  plat.vcloud_name "ubuntu-1004-x86_64"
end
