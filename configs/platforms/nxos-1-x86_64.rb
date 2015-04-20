platform "nxos-1-x86_64" do |plat|
  plat.servicedir "/etc/init.d"
  plat.defaultdir "/etc/sysconfig"
  plat.servicetype "sysv"
  plat.provision_with "echo"
  plat.install_build_dependencies_with "echo "
  plat.docker_image "nxos_base_image"
  plat.ssh_port 2222
end
