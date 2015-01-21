platform "eos-4-i386" do |plat|
  plat.servicedir "/etc/rc.d/init.d"
  plat.defaultdir "/etc/sysconfig"
  plat.servicetype "sysv"

  plat.provision_with %Q{
echo '[device-upstream]
name=device-upstream
gpgcheck=0
baseurl=http://osmirror.delivery.puppetlabs.net/eos-4-i386/RPMS.all/' > /etc/yum.repos.d/device-upstream.repo
yum install -y --nogpgcheck autoconf automake createrepo rsync gcc make rpm-build rpm-libs yum-utils
}

  plat.install_build_dependencies_with "yum install -y --nogpgcheck"
  plat.vcloud_name "fedora-14-i386"
end
