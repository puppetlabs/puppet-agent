platform "el-8-aarch64" do |plat|
  plat.inherit_from_default

  plat.clear_provisioning

  packages = %w(gcc-c++ rsync cmake-3.11.4 make rpm-libs rpm-build)
  plat.provision_with "dnf install -y --allowerasing #{packages.join(' ')}"
end
