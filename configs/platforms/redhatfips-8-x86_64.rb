platform "redhatfips-8-x86_64" do |plat|
  # Uncomment the following line when a vanagon with defaults for this platform is released
  # plat.inherit_from_default

  # Delete everything below when a vanagon with defaults for this platform is released
  plat.servicedir "/usr/lib/systemd/system"
  plat.defaultdir "/etc/sysconfig"
  plat.servicetype "systemd"

  packages = %w(
    cmake
    gcc-c++
    java-1.8.0-openjdk-devel
    libarchive
    libsepol-devel
    libselinux-devel
    openssl-devel
    pkgconfig
    readline-devel
    rpm-build
    rpmdevtools
    rsync
    swig
    systemtap-sdt-devel
    yum-utils
    zlib-devel
  )
  plat.provision_with("dnf install -y --allowerasing  #{packages.join(' ')}")
  plat.install_build_dependencies_with "yum install --assumeyes"
  plat.vmpooler_template "redhat-fips-8-x86_64"
end
