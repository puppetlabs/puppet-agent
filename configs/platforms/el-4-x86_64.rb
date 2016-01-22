platform "el-4-x86_64" do |plat|
  plat.servicedir "/etc/rc.d/init.d"
  plat.defaultdir "/etc/sysconfig"
  plat.servicetype "sysv"
  plat.tar "/opt/pl-build-tools/bin/tar"

  plat.add_build_repository "http://pl-build-tools.delivery.puppetlabs.net/yum/pl-build-tools-release-#{plat.get_os_name}-#{plat.get_os_version}.noarch.rpm"
  plat.provision_with "echo '[build-tools]\nname=build-tools\ngpgcheck=0\nbaseurl=http://enterprise.delivery.puppetlabs.net/build-tools/el/4/$basearch' > /etc/yum.repos.d/build-tools.repo;yum install -y autoconf automake createrepo rsync gcc make rpm-build rpm-libs yum-utils pl-tar; yum update -y pkgconfig"
  plat.install_build_dependencies_with "yum install -y"
  plat.vmpooler_template "centos-4-x86_64"
end
