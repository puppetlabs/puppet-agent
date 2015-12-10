platform "debian-6-amd64" do |plat|
  plat.servicedir "/etc/init.d"
  plat.defaultdir "/etc/default"
  plat.servicetype "sysv"
  plat.codename "squeeze"

  plat.apt_repo "http://pl-build-tools.delivery.puppetlabs.net/debian/pl-build-tools-release-squeeze.deb"
  plat.provision_with "export DEBIAN_FRONTEND=noninteractive; apt-get update -qq; apt-get install -qy --no-install-recommends build-essential devscripts make quilt pkg-config debhelper "
  plat.install_build_dependencies_with "DEBIAN_FRONTEND=noninteractive; apt-get install -qy --no-install-recommends "
  plat.vmpooler_template "debian-6-x86_64"
end
