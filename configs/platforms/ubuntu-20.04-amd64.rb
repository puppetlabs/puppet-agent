platform "ubuntu-20.04-amd64" do |plat|
  plat.servicedir "/lib/systemd/system"
  plat.defaultdir "/etc/default"
  plat.servicetype "systemd"
  plat.codename "focal"

  # FIXME
  # this is needed since `apt-get install devscripts` updated libc to a version that is not compatible
  # with the version installed by default om vmpooler images.
  # To overcome this:
  # - `devscripts` package in no longer upgraded (since is already installed)
  # - `libc6` marked as hold to detect early packages trying to update it
  #
  # This workaround should be removed when image is updated with released iso version
  #
  plat.provision_with "apt-mark hold libc6"

  plat.provision_with "export DEBIAN_FRONTEND=noninteractive; apt-get update -qq; apt-get install -qy --no-install-recommends build-essential make quilt pkg-config debhelper rsync fakeroot cmake"
  plat.install_build_dependencies_with "DEBIAN_FRONTEND=noninteractive; apt-get install -qy --no-install-recommends "
  plat.vmpooler_template "ubuntu-2004-x86_64"
end
