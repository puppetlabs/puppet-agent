platform "el-5-i386" do |plat|
#  plat.tool :make => "/usr/bin/make"
#  plat.tool :patch => "/usr/bin/patch"
#  plat.service { :type => "sysv", :defaultdir => "/etc/sysconfig", :servicedir => "/etc/rc.d/init.d" }
  plat.make = "/usr/bin/make"
  plat.patch = "/usr/bin/patch"
  plat.servicedir = "/etc/rc.d/init.d"
  plat.defaultdir = "/etc/sysconfig"
  plat.servicetype = "sysv"

  plat.provision_with "echo 'y' | yum install --nogpgcheck autoconf automake createrepo rsync gcc make rpmdevtools rpm-libs yum-utils rpm-sign rpm-build; echo '[build-tools]\nname=build-tools\nbaseurl=http://enterprise.delivery.puppetlabs.net/build-tools/el/5/$basearch' > /etc/yum.repos.d/build-tools.repo"
  plat.install_build_dependencies_with "echo 'y' | yum install --nogpgcheck "
  plat.vcloud_name = "centos-5-i386"
end
