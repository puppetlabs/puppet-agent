platform "huaweios-6-powerpc" do |plat|
  plat.servicedir "/etc/init.d"
  plat.defaultdir "/etc/default"
  # HuaweiOS is based on Debian 8 but uses sysv instead of systemd
  plat.servicetype "sysv"
  plat.codename "huaweios"

  plat.add_build_repository "http://pl-build-tools.delivery.puppetlabs.net/debian/pl-build-tools-release-#{plat.get_codename}.deb"
  plat.provision_with "export DEBIAN_FRONTEND=noninteractive; apt-get update -qq; apt-get install -qy --no-install-recommends binutils-powerpc-linux-gnu build-essential devscripts make quilt pkg-config debhelper rsync fakeroot"
  plat.install_build_dependencies_with "DEBIAN_FRONTEND=noninteractive; apt-get install -qy --no-install-recommends "
  plat.cross_compiled true
  plat.vmpooler_template "debian-8-x86_64"
end
