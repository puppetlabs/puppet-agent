platform "aix-7.1-ppc" do |plat|
  # patch AIX platform to set the rpm filename to 7.1 instead of 6.1
  plat._platform.define_singleton_method(:rpm_defines) do
    %(--define '_topdir $(tempdir)/rpmbuild' --define '_rpmfilename %%{ARCH}/%%{NAME}-%%{VERSION}-%%{RELEASE}.aix7.1.%%{ARCH}.rpm')
  end

  plat.servicetype "aix"

  plat.make "gmake"
  plat.tar "/opt/freeware/bin/tar"
  plat.rpmbuild "/usr/bin/rpm"
  plat.patch "/opt/freeware/bin/patch"

  # Basic vanagon operations require mktemp, rsync, coreutils, make, tar and sed so leave this in there
  packages = [
    "https://artifactory.delivery.puppetlabs.net/artifactory/rpm__remote_oss4aix.org/RPMS/mktemp/mktemp-1.7-1.aix5.1.ppc.rpm",
    "https://artifactory.delivery.puppetlabs.net/artifactory/rpm__remote_aix_linux_toolbox/RPMS/ppc/rsync/rsync-3.0.6-1.aix5.3.ppc.rpm",
    "https://artifactory.delivery.puppetlabs.net/artifactory/rpm__remote_aix_linux_toolbox/RPMS/ppc/coreutils/coreutils-5.2.1-2.aix5.1.ppc.rpm",
    "https://artifactory.delivery.puppetlabs.net/artifactory/rpm__remote_aix_linux_toolbox/RPMS/ppc/sed/sed-4.1.1-1.aix5.1.ppc.rpm",
    "https://artifactory.delivery.puppetlabs.net/artifactory/rpm__remote_aix_linux_toolbox/RPMS/ppc/make/make-4.1-2.aix6.1.ppc.rpm",
    "https://artifactory.delivery.puppetlabs.net/artifactory/rpm__remote_aix_linux_toolbox/RPMS/ppc/tar/tar-1.22-1.aix6.1.ppc.rpm",
  ]

  packages.each do |uri|
    name = uri.split("/").last
    plat.provision_with("curl -O #{uri} > /dev/null")
    plat.provision_with("rpm -Uvh --replacepkgs --nodeps #{name}")
  end

  # We use --force with rpm because the pl-gettext and pl-autoconf
  # packages conflict with a charset.alias file.
  #
  # Until we get those packages to not conflict (or we remove the need
  # for pl-autoconf) we'll need to force the installation
  #                                         Sean P. McD.
  plat.install_build_dependencies_with "rpm -Uvh --replacepkgs --force "
  plat.vmpooler_template "aix-6.1-power"
end
