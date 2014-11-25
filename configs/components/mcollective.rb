component "mcollective" do |pkg, settings, platform|
  pkg.version "2.6.0.5"
  pkg.md5sum "f0876fe5e13d2128fe6e5319478661ba"
  pkg.url "http://builds.puppetlabs.lan/pe-mcollective/2.6.0.5/artifacts/pe-mcollective-2.6.0.5.tar.gz"

  pkg.build_requires "ruby"
  pkg.build_requires "ruby-stomp"

  case platform[:servicetype]
  when "systemd"
    pkg.add_service_file "#{platform[:servicedir]}/mcollective.service"
    pkg.add_service_file "#{platform[:defaultdir]}/mcollective"
    install = [ "cp -pr ext/redhat/pe-mcollective.service #{platform[:servicedir]}/mcollective.service",
                "cp -pr ext/redhat/pe-mcollective.sysconfig #{platform[:defaultdir]}/mcollective"]
  when "sysv"
    pkg.add_service_file "#{platform[:servicedir]}/mcollective"
    pkg.add_service_file "#{platform[:defaultdir]}/mcollective"
    install = [ "cp -pr ext/redhat/pe-mcollective.init-rh #{platform[:servicedir]}/mcollective",
                "cp -pr ext/redhat/pe-mcollective.sysconfig #{platform[:defaultdir]}/mcollective"]
  else
    fail "need to know where to put service files"
  end

  pkg.install do
    ["#{settings[:bindir]}/ruby install.rb --plugindir=#{settings[:prefix]}/mcollective/plugins --configdir=#{settings[:sysconfdir]} --sitelibdir=#{settings[:ruby_vendordir]} --configs --quick --man --mandir=#{settings[:mandir]}",
     install]
  end
end
