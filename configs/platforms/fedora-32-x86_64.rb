platform "fedora-32-x86_64" do |plat|
  plat.servicedir "/usr/lib/systemd/system"
  plat.defaultdir "/etc/sysconfig"
  plat.servicetype "systemd"
  plat.dist "fc32"


  packages = ['make', 'rsync', 'rpm-build']
  plat.provision_with "/usr/bin/dnf install -y --best --allowerasing #{packages.join(' ')}"
  plat.install_build_dependencies_with "/usr/bin/dnf install -y --best --allowerasing"

  plat.vmpooler_template "fedora-32-x86_64"
end
