platform "sles-11-x86_64" do |plat|
  plat.servicedir "/etc/init.d"
  plat.defaultdir "/etc/sysconfig"
  plat.servicetype "sysv"
  packages = ["make", "rsync"]
  plat.provision_with "zypper -n --no-gpg-checks install -y #{packages.join(' ')}"
  plat.install_build_dependencies_with "zypper -n --no-gpg-checks install -y"
  plat.vmpooler_template "sles-11-x86_64"
end
