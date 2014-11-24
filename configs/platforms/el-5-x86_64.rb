platform "el-5-x86_64" do |plat|
  plat.make = "/usr/bin/make"
  plat.patch = "/usr/bin/patch"
  plat.servicedir = "/etc/rc.d/init.d"
  plat.defaultdir = "/etc/sysconfig"
  plat.servicetype = "sysv"

  plat.provision_with "echo 'y' | yum install autoconf automake createrepo rsync gcc make rpmdevtools rpm-libs yum-utils rpm-sign rpm-build; echo '[build-tools]\nname=build-tools\nbaseurl=http://enterprise.delivery.puppetlabs.net/build-tools/el/5/$basearch\ngpgcheck=0' > /etc/yum.repos.d/build-tools.repo"
  plat.install_build_dependencies_with "echo 'y' | yum install "
  plat.vcloud_name = "centos-5-x86_64"
end
