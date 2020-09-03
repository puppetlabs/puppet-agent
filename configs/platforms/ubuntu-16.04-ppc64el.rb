platform "ubuntu-16.04-ppc64el" do |plat|
  plat.servicedir "/lib/systemd/system"
  plat.defaultdir "/etc/default"
  plat.servicetype "systemd"
  plat.codename "xenial"

  plat.add_build_repository "http://pl-build-tools.delivery.puppetlabs.net/debian/pl-build-tools-release-#{plat.get_codename}.deb"
  packages = ['build-essential', 'devscripts', 'rsync', 'fakeroot', 'debhelper', 'binutils-powerpc64le-linux-gnu']
  plat.provision_with "export DEBIAN_FRONTEND=noninteractive; apt-get update -qq; apt-get install -qy --no-install-recommends #{packages.join(' ')}"
  plat.install_build_dependencies_with "DEBIAN_FRONTEND=noninteractive; apt-get install -qy --no-install-recommends "
  plat.cross_compiled true
  plat.vmpooler_template "ubuntu-1604-x86_64"
end
