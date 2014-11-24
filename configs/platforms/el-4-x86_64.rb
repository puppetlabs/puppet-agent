platform "el-4-x86_64" do |plat|
  plat.make = "/usr/bin/make"
  plat.patch = "/usr/bin/patch"
  plat.servicedir = "/etc/rc.d/init.d"
  plat.defaultdir = "/etc/sysconfig"
  plat.servicetype = "sysv"

  plat.provision_with "echo '[build-tools]\nname=build-tools\ngpgcheck=0\nbaseurl=http://enterprise.delivery.puppetlabs.net/build-tools/el/4/$basearch' > /etc/yum.repos.d/build-tools.repo;yum install -y autoconf automake createrepo rsync gcc make rpm-build rpm-libs yum-utils;yum update -y pkgconfig"
  plat.install_build_dependencies_with "yum install -y"
  plat.vcloud_name = "centos-4-x86_64"
end
