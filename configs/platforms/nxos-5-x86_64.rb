platform "nxos-5-x86_64" do |plat|
  plat.servicedir "/etc/init.d"
  plat.defaultdir "/etc/sysconfig"
  plat.servicetype "sysv"

  plat.provision_with "echo '[pl-build-tools]\nname=pl-build-tools\ngpgcheck=0\nbaseurl=http://pl-build-tools.delivery.puppetlabs.net/yum/nxos/1/$basearch' > /etc/yum/repos.d/pl-build-tools.repo;yum install -y autoconf automake createrepo rsync gcc make rpm-build rpm-libs yum-utils;yum update -y pkgconfig"
  plat.install_build_dependencies_with "yum install -y"

  plat.vcloud_name "nxos-5-x86_64"

end
