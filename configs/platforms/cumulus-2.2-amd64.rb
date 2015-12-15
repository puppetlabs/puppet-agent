platform "cumulus-22-amd64" do |plat|
  plat.servicedir "/etc/init.d"
  plat.defaultdir "/etc/default"
  plat.servicetype "sysv"
  plat.codename "cumulus"

  plat.apt_repo "http://pl-build-tools.delivery.puppetlabs.net/debian/pl-build-tools-release-wheezy.deb"

  plat.provision_with %(
echo 'deb http://enterprise.delivery.puppetlabs.net/build-tools/debian/CumulusLinux CumulusLinux-2.2 build-tools
deb http://osmirror.delivery.puppetlabs.net/cumulus/ CumulusLinux-2.2 main addons security-updates testing updates' > /etc/apt/sources.list
echo 'Package: *
Pin: release n="CumulusLinux-2.2*"
Pin-Priority: 1001' > /etc/apt/preferences.d/cumulus
apt-get update -qq
export DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=none
apt-get dist-upgrade -qy --force-yes -o Dpkg::Options::="--force-confold" --allow-unauthenticated
echo 'deb http://osmirror.delivery.puppetlabs.net/debian/ wheezy main
deb http://osmirror.delivery.puppetlabs.net/debian/ wheezy-updates main' >> /etc/apt/sources.list
apt-get update -qq
apt-get install -qy --no-install-recommends build-essential make quilt pkg-config debhelper devscripts
)

  plat.install_build_dependencies_with "DEBIAN_FRONTEND=noninteractive; apt-get install -qy --no-install-recommends "
  plat.vmpooler_template "debian-7-x86_64"
end
