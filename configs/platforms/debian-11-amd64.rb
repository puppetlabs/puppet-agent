platform "debian-11-amd64" do |plat|
  # Delete the lines below when a vanagon with Debian 11 support is released
  plat.servicedir "/lib/systemd/system"
  plat.defaultdir "/etc/default"
  plat.servicetype "systemd"
  plat.codename "bullseye"
  plat.vmpooler_template "debian-11-x86_64"
  plat.install_build_dependencies_with "DEBIAN_FRONTEND=noninteractive; apt-get install -qy --no-install-recommends "
  packages = %w(build-essential devscripts debhelper rsync fakeroot)
  plat.provision_with "export DEBIAN_FRONTEND=noninteractive; apt-get update -qq; apt-get install -qy --no-install-recommends #{packages.join(' ')}"

  # Uncomment these when a vanagon with Debian 11 support is released
  # plat.inherit_from_default
  # plat.clear_provisioning
end
