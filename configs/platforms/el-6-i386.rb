platform "el-6-i386" do |plat|
  plat.servicedir "/etc/rc.d/init.d"
  plat.defaultdir "/etc/sysconfig"
  plat.servicetype "sysv"

  packages = ['make', 'rsync', 'rpm-build']
  plat.provision_with "yum install --assumeyes #{packages.join(' ')}"
  plat.install_build_dependencies_with "yum install --assumeyes"
  plat.vmpooler_template "redhat-6-i386"
end
