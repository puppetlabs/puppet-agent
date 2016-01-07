platform "aix-5.3-ppc" do |plat|
  plat.servicetype "aix"

  plat.make "gmake"
  plat.tar "/opt/freeware/bin/tar"
  plat.rpmbuild "/usr/bin/rpm"
  plat.patch "/opt/freeware/bin/patch"

  # This is how we clean up our last build since we don't have a pooler image
  plat.provision_with "rpm --quiet -e autoconf binutils coreutils diffutils expect gcc gcc-c++ libgcc libstdc++ libstdc++-devel libxml2 libxml2-devel m4 make mktemp pkg-config pl-boost pl-cmake pl-gcc pl-yaml-cpp readline readline-devel screen sed tcl tk which zlib-devel cdrecord mkisofs ; rm -rf /opt/pl-build-tools /opt/puppetlabs /etc/puppetlabs /var/log/puppetlabs /var/tmp/tmp.* /var/tmp/*root-root /var/tmp/rpm* /root/*.jam; test -f /opt/freeware/bin/granlib  && chmod 755 /opt/freeware/bin/granlib || true"

  # Basic vanagon operations require mktemp, rsync, coreutils, tar and sed so leave this in there
  plat.provision_with "rpm -Uvh --replacepkgs http://osmirror.delivery.puppetlabs.net/AIX_MIRROR/mktemp-1.7-1.aix5.1.ppc.rpm http://osmirror.delivery.puppetlabs.net/AIX_MIRROR/rsync-3.0.6-1.aix5.3.ppc.rpm http://osmirror.delivery.puppetlabs.net/AIX_MIRROR/coreutils-5.2.1-2.aix5.1.ppc.rpm http://osmirror.delivery.puppetlabs.net/AIX_MIRROR/sed-4.1.1-1.aix5.1.ppc.rpm http://osmirror.delivery.puppetlabs.net/AIX_MIRROR/make-3.80-1.aix5.1.ppc.rpm http://osmirror.delivery.puppetlabs.net/AIX_MIRROR/tar-1.14-2.aix5.1.ppc.rpm"

  plat.install_build_dependencies_with "rpm -Uvh --replacepkgs "
  plat.build_host ["pe-aix-53-builder.delivery.puppetlabs.net"]
end
