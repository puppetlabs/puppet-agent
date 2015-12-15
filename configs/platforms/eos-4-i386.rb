platform "eos-4-i386" do |plat|
  plat.servicedir "/etc/rc.d/init.d"
  plat.defaultdir "/etc/sysconfig"
  plat.servicetype "sysv"

  plat.yum_repo "http://pl-build-tools.delivery.puppetlabs.net/yum/fedora/14/i386/pl-build-tools-fedora-14.repo"
  plat.yum_repo "http://osmirror.delivery.puppetlabs.net/eos-4-i386/eos-4-i386.repo"
  plat.provision_with "yum install -y --nogpgcheck autoconf automake createrepo rsync gcc make rpm-build rpm-libs yum-utils zip"

  plat.install_build_dependencies_with "yum install -y --nogpgcheck"
  plat.vmpooler_template "fedora-14-i386"
end
