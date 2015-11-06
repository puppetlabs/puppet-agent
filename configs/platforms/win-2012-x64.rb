platform "win-2012-x64" do |plat|
  plat.vmpooler_template "win-2012r2-x86_64"
  plat.codename "windows"
  # Will need to change to Windows specific services - use systemd for now.
  plat.servicetype "systemd"

  plat.servicedir "/lib/systemd/system"
  plat.defaultdir "/etc/default"

  plat.provision_with "echo provision_with"
  plat.install_build_dependencies_with "echo build_dependencies"
end
