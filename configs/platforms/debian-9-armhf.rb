platform "debian-9-armhf" do |plat|
  plat.servicedir "/lib/systemd/system"
  plat.defaultdir "/etc/default"
  plat.servicetype "systemd"
  plat.codename "stretch"

  plat.provision_with "export DEBIAN_FRONTEND=noninteractive; apt-get update ; apt-get install -qq -y --no-install-recommends build-essential devscripts make quilt pkg-config debhelper rsync fakeroot gcc-arm-linux-gnueabihf binutils-arm-linux-gnueabihf cpp-arm-linux-gnueabihf g++-arm-linux-gnueabihf curl"
  plat.provision_with "cd /etc/apt/sources.list.d/; curl -L -o armhf.list https://gist.githubusercontent.com/stahnma/c344a17f58073faa099f43a176d04330/raw/855666deb56338d6bf131c9f5e0501dcec9adcd4/gistfile1.txt; apt-get -qq update; dpkg --add-architecture armhf"
  plat.install_build_dependencies_with "DEBIAN_FRONTEND=noninteractive; apt-get install -qq -qy --no-install-recommends "
  plat.vmpooler_template "debian-9-x86_64"
  plat.cross_compiled "true"
  plat.native_tools "true"
  plat.output_dir File.join("deb", plat.get_codename, "PC1")
end
