platform "debian-9-armhf" do |plat|
  plat.servicedir "/lib/systemd/system"
  plat.defaultdir "/etc/default"
  plat.servicetype "systemd"
  plat.codename "stretch"

  plat.provision_with "export DEBIAN_FRONTEND=noninteractive; apt-get update ; apt-get install -qq -y --no-install-recommends build-essential devscripts make quilt pkg-config debhelper rsync fakeroot binutils-arm-linux-gnueabihf g++-6-arm-linux-gnueabihf"
  plat.install_build_dependencies_with "DEBIAN_FRONTEND=noninteractive; apt-get install -qq -qy --no-install-recommends "
  plat.vmpooler_template "debian-9-x86_64"
  plat.cross_compiled "true"
  plat.output_dir File.join("deb", plat.get_codename, "PC1")
end
