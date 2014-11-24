platform "sles-10-i386" do |plat|
  plat.make = "/usr/bin/make"
  plat.patch = "/usr/bin/patch"
  plat.servicedir = "/etc/init.d"
  plat.defaultdir = "/etc/sysconfig"
  plat.servicetype = "sysv"

  plat.provision_with "zypper install -y autoconf automake createrepo rsync gcc make rsync"
  plat.install_build_dependencies_with "zypper install -y"
  plat.vcloud_name = "sles-10-i386"
end
