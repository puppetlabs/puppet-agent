platform "cisco-wrlinux-7-x86_64" do |plat|
  plat.servicedir "/etc/init.d"
  plat.defaultdir "/etc/sysconfig"
  plat.servicetype "sysv"
  # The development environment provided by Cisco includes the build dependencies
  # such as autoconf automake createrepo rsync gcc make rpm-build rpm-libs yum-utils
  plat.yum_repo "http://pl-build-tools.delivery.puppetlabs.net/yum/cisco-wrlinux/7/pl-build-tools-cisco-wrlinux-7.repo"
  plat.install_build_dependencies_with "yum install -y"
  plat.vmpooler_template "cisco-wrlinux-7-x86_64"
end
