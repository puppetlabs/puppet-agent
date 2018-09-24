platform "el-7-s390" do |plat|
  # Note: This is a community-maintained platform. It is not tested in Puppet's
  # CI pipelines, and does not receive official releases.
  plat.servicedir "/usr/lib/systemd/system"
  plat.defaultdir "/etc/sysconfig"
  plat.servicetype "systemd"

  # The s390 builds from IBM can't talk to our internal systems.
  #plat.add_build_repository "http://pl-build-tools.delivery.puppetlabs.net/yum/el/7/x86_64/pl-build-tools-release-7-1.noarch.rpm"
  plat.provision_with "yum install --assumeyes autoconf automake createrepo rsync gcc make rpmdevtools rpm-libs yum-utils rpm-sign"
  plat.install_build_dependencies_with "yum install --assumeyes"
end
