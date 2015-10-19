platform "el-7-s390" do |plat|
  plat.servicedir "/usr/lib/systemd/system"
  plat.defaultdir "/etc/sysconfig"
  plat.servicetype "systemd"

  # The s390 builds from IBM can't talk to our internal systems.
  #plat.yum_repo "http://pl-build-tools.delivery.puppetlabs.net/yum/el/7/x86_64/pl-build-tools-release-7-1.noarch.rpm"
  plat.provision_with "yum install --assumeyes autoconf automake createrepo rsync gcc make rpmdevtools rpm-libs yum-utils rpm-sign"
  plat.install_build_dependencies_with "yum install --assumeyes"
end
