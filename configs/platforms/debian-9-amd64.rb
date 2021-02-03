platform "debian-9-amd64" do |plat|
  plat.defaultdir "/etc/default"
  plat.servicetype "systemd", servicedir: "/lib/systemd/system"
  plat.servicetype "sysv", servicedir: "/etc/init.d"
  plat.codename "stretch"

  packages = ['build-essential', 'devscripts', 'rsync', 'fakeroot', 'debhelper']
  plat.provision_with "export DEBIAN_FRONTEND=noninteractive; apt-get update -qq; apt-get install -qy --no-install-recommends #{packages.join(' ')}"
  plat.install_build_dependencies_with "DEBIAN_FRONTEND=noninteractive; apt-get install -qy --no-install-recommends "
  plat.vmpooler_template "debian-9-x86_64"
end
