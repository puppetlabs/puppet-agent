platform "aix-7.1-ppc" do |plat|
  plat.servicetype "aix"

  plat.make "gmake"
  plat.tar "/opt/freeware/bin/tar"
  plat.rpmbuild "/usr/bin/rpmbuild"
  plat.patch "/opt/freeware/bin/patch"
  plat.mktemp "/opt/freeware/bin/mktemp --directory --tmpdir=/var/tmp"
  os_version = 7.1
  plat.environment "CC", "/opt/pl-build-tools/bin/gcc"

  # Bootstrap yum
  plat.provision_with "curl -O http://pl-build-tools.delivery.puppetlabs.net/aix/yum_bootstrap/rpm.rte && installp -acXYgd . rpm.rte all"
  plat.provision_with "curl http://pl-build-tools.delivery.puppetlabs.net/aix/yum_bootstrap/openssl-1.0.2.1500.tar | tar xvf - && cd openssl-1.0.2.1500 && installp -acXYgd . openssl.base all"
  plat.provision_with "rpm --rebuilddb && updtvpkg"
  plat.provision_with "mkdir -p /tmp/yum_bundle && cd /tmp/yum_bundle/ && curl -O http://pl-build-tools.delivery.puppetlabs.net/aix/yum_bootstrap/yum_bundle.tar && tar xvf yum_bundle.tar && rpm -Uvh /tmp/yum_bundle/*.rpm"

  # Add pl-build-tools repo config
  plat.provision_with "echo '[pl-build-tools]\nname=Puppet Labs Build Tools Repository for AIX 7\nbaseurl=http://pl-build-tools.delivery.puppetlabs.net/yum/aix/7.1/$basearch\ngpgcheck=0' > /opt/freeware/etc/yum/repos.d/pl-build-tools.repo"

  # Use artifactory mirror for AIX toolbox packages
  plat.provision_with "/usr/bin/sed 's/enabled=1/enabled=0/g' /opt/freeware/etc/yum/yum.conf > tmp.$$ && mv tmp.$$ /opt/freeware/etc/yum/yum.conf"
  plat.provision_with "echo '[AIX_Toolbox_mirror]\nname=AIX Toolbox local mirror\nbaseurl=https://artifactory.delivery.puppetlabs.net/artifactory/rpm__remote_aix_linux_toolbox/RPMS/ppc/\ngpgcheck=0' > /opt/freeware/etc/yum/repos.d/toolbox-generic-mirror.repo"
  plat.provision_with "echo '[AIX_Toolbox_noarch_mirror]\nname=AIX Toolbox noarch repository\nbaseurl=https://artifactory.delivery.puppetlabs.net/artifactory/rpm__remote_aix_linux_toolbox/RPMS/noarch/\ngpgcheck=0' > /opt/freeware/etc/yum/repos.d/toolbox-noarch-mirror.repo"
  plat.provision_with "echo '[AIX_Toolbox_71_mirror]\nname=AIX 71 specific repository\nbaseurl=https://artifactory.delivery.puppetlabs.net/artifactory/rpm__remote_aix_linux_toolbox/RPMS/ppc-7.1/\ngpgcheck=0' > /opt/freeware/etc/yum/repos.d/toolbox-71-mirror.repo"

  # Install build dependencies
  plat.provision_with "yum install -y pl-gcc pl-cmake pl-yaml-cpp pl-boost coreutils autoconf gawk-3.1.3-1 pkg-config-0.19-6 rsync sed make tar glib2 perl zlib-1.2.3-4 zlib-devel-1.2.3-4"

  plat.install_build_dependencies_with "yum install -y"
  plat.vmpooler_template "aix-7.1-power"
end
