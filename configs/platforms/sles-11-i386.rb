platform "sles-11-i386" do |plat|
  plat.servicedir "/etc/init.d"
  plat.defaultdir "/etc/sysconfig"
  plat.servicetype "sysv"

  plat.zypper_repo "http://pl-build-tools.delivery.puppetlabs.net/yum/sles/11/i386/pl-build-tools-sles-11-i386.repo"
  plat.provision_with "zypper -n --no-gpg-checks install -y aaa_base autoconf automake rsync gcc make"
  plat.install_build_dependencies_with "zypper -n --no-gpg-checks install -y"
  plat.vmpooler_template "sles-11-i386"
end
