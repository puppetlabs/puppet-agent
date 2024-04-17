platform 'el-9-ppc64le' do |plat|
  plat.inherit_from_default

  packages = %w(gcc gcc-c++ autoconf automake createrepo rsync cmake make rpm-libs rpm-build libarchive)
  plat.provision_with "dnf install -y --allowerasing #{packages.join(' ')}"
  plat.install_build_dependencies_with 'dnf install -y --allowerasing '
  plat.vmpooler_template 'redhat-9-power9'
end
