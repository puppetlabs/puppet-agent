platform "sles-12-x86_64" do |plat|
  plat.servicedir "/usr/lib/systemd/system"
  plat.defaultdir "/etc/sysconfig"
  plat.servicetype "systemd"

  plat.provision_with "zypper install -y autoconf automake createrepo rsync gcc make rpm-build"
  plat.install_build_dependencies_with "zypper install -y"
  plat.vcloud_name "sles-12-x86_64"
end
