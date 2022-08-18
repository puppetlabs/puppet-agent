platform 'fedora-36-x86_64' do |plat|
  plat.servicedir '/usr/lib/systemd/system'
  plat.defaultdir '/etc/sysconfig'
  plat.servicetype 'systemd'
  plat.dist 'fc36'

  # There's an issue with the version of binutils (2.37) in Fedora 36's repos
  # We temporarily use a newer version from rawhide. See PA-4448
  plat.provision_with('/usr/bin/dnf install -y fedora-repos-rawhide')
  plat.provision_with('/usr/bin/dnf install -y --enablerepo rawhide binutils')

  packages = %w[
    autoconf automake bzip2-devel gcc gcc-c++ libselinux-devel
    libsepol libsepol-devel make cmake pkgconfig readline-devel
    rpmdevtools rsync swig zlib-devel systemtap-sdt-devel
    perl-lib perl-FindBin
  ]
  plat.provision_with("/usr/bin/dnf install -y --best --allowerasing #{packages.join(' ')}")

  plat.install_build_dependencies_with '/usr/bin/dnf install -y --best --allowerasing'
  plat.vmpooler_template 'fedora-36-x86_64'
end
