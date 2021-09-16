platform "redhatfips-8-x86_64" do |plat|
  # Uncomment the lines below when a vanagon with defaults for this platform is released
  # plat.inherit_from_default
  # plat.clear_provisioning

  packages = %w(rpm-build rpmdevtools rsync yum-utils)
  plat.provision_with("dnf install -y --allowerasing  #{packages.join(' ')}")

  # Delete everything below when a vanagon with defaults for this platform is released
  plat.servicedir "/usr/lib/systemd/system"
  plat.defaultdir "/etc/sysconfig"
  plat.servicetype "systemd"
  plat.install_build_dependencies_with "yum install --assumeyes"
  plat.vmpooler_template "redhat-fips-8-x86_64"
end
