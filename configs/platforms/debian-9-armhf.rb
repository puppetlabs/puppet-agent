platform "debian-9-armhf" do |plat|
  plat.servicedir "/lib/systemd/system"
  plat.defaultdir "/etc/default"
  plat.servicetype "systemd"
  plat.codename "stretch"


  plat.provision_with %(
    export DEBIAN_FRONTEND=noninteractive; apt-get update
    apt-get install -qq -y --no-install-recommends build-essential devscripts make quilt \
    pkg-config debhelper rsync fakeroot gcc-arm-linux-gnueabihf binutils-arm-linux-gnueabihf \
    cpp-arm-linux-gnueabihf g++-arm-linux-gnueabihf curl)

  # You can't use plat.add_build_repository for this because the format is not
  # exactly what is expected. This is to enable this specific architecture on
  # amd64 hosts. (As is the next line)
  #
  # This can be removed if Puppet is no longer using OSmirror but using a real debian mirror with all arches.
  plat.provision_with %(
    echo  "deb [arch=#{plat.get_architecture}] http://deb.debian.org/debian #{plat.get_codename} main" >> /etc/apt/sources.list.d/#{plat.get_architecture}.list
    echo  "deb [arch=#{plat.get_architecture}] http://deb.debian.org/debian #{plat.get_codename}-updates main" >> /etc/apt/sources.list.d/#{plat.get_architecture}.list
    echo  "deb [arch=#{plat.get_architecture}] http://security.debian.org/debian-security/ #{plat.get_codename}/updates main" >> /etc/apt/sources.list.d/#{plat.get_architecture}.list
  apt-get -qq update; dpkg --add-architecture #{plat.get_architecture}
  )

  plat.install_build_dependencies_with "DEBIAN_FRONTEND=noninteractive; apt-get install -qq -qy --no-install-recommends "
  plat.vmpooler_template "debian-9-x86_64"
  plat.cross_compiled "true"
  plat.output_dir File.join("deb", plat.get_codename, "PC1")
end
