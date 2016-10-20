platform "el-4-x86_64" do |plat|
  plat.servicedir "/etc/rc.d/init.d"
  plat.defaultdir "/etc/sysconfig"
  plat.servicetype "sysv"
  plat.tar "/opt/pl-build-tools/bin/tar"

  plat.add_build_repository "http://pl-build-tools.delivery.puppetlabs.net/yum/pl-build-tools-release-#{plat.get_os_name}-#{plat.get_os_version}.noarch.rpm"
  # The following provisions yum on redhat 4 by doing the following:
  #    - Use osmirror of centos 4 to grab and install yum and it's deps
  #    - Remove the default Centos-Base.repo config (which won't work for redhat)
  #    - create a vault.repo config to grab regular packages (like gcc)
  #
  # Then the remainder of the provisioning process remains the same
  #
  # When the centos-4-x86_64 pooler images are available again, we can
  # revert this work and begin using centos again
  #                       - Sean P. McDonald  10/20/16
  plat.provision_with %(

rpm -ivh http://osmirror.delivery.puppetlabs.net/cent4latestserver-x86_64/RPMS.all/sqlite-3.3.6-2.x86_64.rpm && \
rpm -ivh http://osmirror.delivery.puppetlabs.net/cent4latestserver-x86_64/RPMS.all/python-sqlite-1.1.7-1.2.1.x86_64.rpm && \
rpm -ivh http://osmirror.delivery.puppetlabs.net/cent4latestserver-x86_64/RPMS.all/python-elementtree-1.2.6-5.el4.centos.x86_64.rpm && \
rpm -ivh http://osmirror.delivery.puppetlabs.net/cent4latestserver-x86_64/RPMS.all/python-urlgrabber-2.9.8-2.noarch.rpm && \
rpm -ivh http://osmirror.delivery.puppetlabs.net/cent4latestserver-x86_64/RPMS.all/yum-metadata-parser-1.0-8.el4.centos.x86_64.rpm && \
rpm -ivh http://osmirror.delivery.puppetlabs.net/cent40server-x86_64/RPMS.updates/centos-yumconf-4-4.2.noarch.rpm && \
rpm -ivh http://osmirror.delivery.puppetlabs.net/cent4latestserver-x86_64/RPMS.all/yum-2.4.3-4.el4.centos.noarch.rpm && \

rm -f /etc/yum.repos.d/CentOS-Base.repo && \

echo -e '\n[base]\nname=CentOS-$releasever - Base\nbaseurl=http://vault.centos.org/4.9/os/$basearch/\ngpgcheck=1\ngpgkey=http://vault.centos.org/RPM-GPG-KEY-centos4\nprotect=1\npriority=1\n\n#released updates\n[update]\nname=CentOS-$releasever - Updates\nbaseurl=http://vault.centos.org/4.9/updates/$basearch/\ngpgcheck=1\ngpgkey=http://vault.centos.org/RPM-GPG-KEY-centos4\nprotect=1\npriority=1\n\n#packages used/produced in the build but not released\n[addons]\nname=CentOS-$releasever - Addons\nbaseurl=http://vault.centos.org/4.9/addons/$basearch/\ngpgcheck=1\ngpgkey=http://vault.centos.org/RPM-GPG-KEY-centos4\nprotect=1\npriority=1\n\n#additional packages that may be useful\n[extras]\nname=CentOS-$releasever - Extras\nbaseurl=http://vault.centos.org/4.9/extras/$basearch/\ngpgcheck=1\ngpgkey=http://vault.centos.org/RPM-GPG-KEY-centos4\nprotect=1\npriority=1\n\n#additional packages that extend functionality of existing packages\n[centosplus]\nname=CentOS-$releasever - Plus\nbaseurl=http://vault.centos.org/4.9/centosplus/$basearch/\ngpgcheck=1\nenabled=0\ngpgkey=http://vault.centos.org/RPM-GPG-KEY-centos4\nprotect=1\npriority=2\n\n#contrib - packages by Centos Users\n[contrib]\nname=CentOS-$releasever - Contrib\nbaseurl=http://vault.centos.org/4.9/contrib/$basearch/\ngpgcheck=1\nenabled=0\ngpgkey=http://vault.centos.org/RPM-GPG-KEY-centos4\nprotect=1\npriority=2' > /etc/yum.repos.d/vault.repo && \

echo -e '[build-tools]\\nname=build-tools\\ngpgcheck=0\\nbaseurl=http://enterprise.delivery.puppetlabs.net/build-tools/el/4/$basearch' > /etc/yum.repos.d/build-tools.repo;yum install -y autoconf automake createrepo rsync gcc make rpm-build rpm-libs yum-utils pl-tar; yum update -y pkgconfig
)
  plat.install_build_dependencies_with "yum install -y"
  plat.vmpooler_template "redhat-4-x86_64"
end
