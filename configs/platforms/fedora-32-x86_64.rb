platform "fedora-32-x86_64" do |plat|
  plat.servicedir "/usr/lib/systemd/system"
  plat.defaultdir "/etc/sysconfig"
  plat.servicetype "systemd"
  plat.dist "fc32"


  plat.provision_with "/usr/bin/dnf install -y --best --allowerasing autoconf automake rsync gcc gcc-c++ make rpmdevtools cmake"

  plat.install_build_dependencies_with "/usr/bin/dnf install -y --best --allowerasing"

  plat.vmpooler_template "fedora-32-x86_64"
end
