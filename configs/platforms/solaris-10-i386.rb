platform "solaris-10-i386" do |plat|
  plat.servicedir "/var/svc/manifest"
  plat.defaultdir "/lib/svc/method"
  plat.servicetype "smf"
  plat.vmpooler_template "solaris-10-x86_64"

  base_pkgs = ['arc', 'gnu-idn', 'gpch', 'gtar', 'hea', 'libm', 'wgetu', 'xcu4']
  base_url = 'http://pl-build-tools.delivery.puppetlabs.net/solaris/10/depends'

  plat.provision_with %[echo "# Write the noask file to a temporary directory
# please see man -s 4 admin for details about this file:
# http://www.opensolarisforum.org/man/man4/admin.html
#
# The key thing we don\'t want to prompt for are conflicting files.
# The other nocheck settings are mostly defensive to prevent prompts
# We _do_ want to check for available free space and abort if there is
# not enough
mail=
# Overwrite already installed instances
instance=overwrite
# Do not bother checking for partially installed packages
partial=nocheck
# Do not bother checking the runlevel
runlevel=nocheck
# Do not bother checking package dependencies (We take care of this)
idepend=nocheck
rdepend=nocheck
# DO check for available free space and abort if there isn\'t enough
space=quit
# Do not check for setuid files.
setuid=nocheck
# Do not check if files conflict with other packages
conflict=nocheck
# We have no action scripts.  Do not check for them.
action=nocheck
# Install to the default base directory.
basedir=default" > /var/tmp/vanagon-noask;
  pkgadd -n -a /var/tmp/vanagon-noask -G -d http://get.opencsw.org/now all;
  /opt/csw/bin/pkgutil -y -i curl rsync gmake pkgconfig ggrep;
  ln -sf /opt/csw/bin/rsync /usr/bin/rsync;
  # RE-6121 openssl 1.0.2e requires functionality not in sytem grep
  ln -sf /opt/csw/bin/ggrep /usr/bin/grep;
  # RE-5250 - Solaris 10 templates are awful
  /opt/csw/bin/pkgutil -l gcc | xargs -I{} pkgrm -n -a /var/tmp/vanagon-noask {};
  /opt/csw/bin/pkgutil -l ruby | xargs -I{} pkgrm -n -a /var/tmp/vanagon-noask {};
  /opt/csw/bin/pkgutil -l readline | xargs -I{} pkgrm -n -a /var/tmp/vanagon-noask {};

  # Install base build dependencies
  for pkg in #{base_pkgs.map { |pkg| "SUNW#{pkg}.pkg.gz" }.join(' ')}; do \
  tmpdir=$(mktemp -p /var/tmp -d); (cd ${tmpdir} && curl -O #{base_url}/${pkg} && gunzip -c ${pkg} | pkgadd -d /dev/stdin -a /var/tmp/vanagon-noask all); \
  done
  ntpdate pool.ntp.org]
end
