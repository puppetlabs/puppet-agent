component "mcollective" do |pkg, settings, platform|
  pkg.version "2.6.0.5"
  pkg.md5sum "f0876fe5e13d2128fe6e5319478661ba"
  pkg.url "http://builds.puppetlabs.lan/pe-mcollective/2.6.0.5/artifacts/pe-mcollective-2.6.0.5.tar.gz"

  pkg.build_requires "ruby"
  pkg.build_requires "ruby-stomp"

  case platform.servicetype
  when "systemd"
    pkg.install_service "ext/redhat/pe-mcollective.service", "ext/redhat/pe-mcollective.sysconfig"
    pkg.install_file "ext/redhat/pe-mcollective-systemd.logrotate", "/etc/logrotate.d/mcollective"
  when "sysv"
    pkg.install_service "ext/redhat/pe-mcollective.init-rh", "ext/redhat/pe-mcollective.sysconfig"
    pkg.install_file "ext/redhat/pe-mcollective-sysv.logrotate", "/etc/logrotate.d/mcollective"
  else
    fail "need to know where to put service files"
  end

  pkg.install do
    ["#{settings[:bindir]}/ruby install.rb --plugindir=#{settings[:prefix]}/mcollective/plugins --configdir=#{settings[:sysconfdir]} --sitelibdir=#{settings[:ruby_vendordir]} --configs --quick --man --mandir=#{settings[:mandir]}"]
  end
end
