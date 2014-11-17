component "mcollective" do |pkg, settings, platform|
  pkg.version = "2.6.0.4"
  pkg.md5sum = "792be7d43c8f9f7e742c7e6a7afb5f5e"
  pkg.url = "http://builds.puppetlabs.lan/pe-mcollective/2.6.0.4/artifacts/pe-mcollective-2.6.0.4.tar.gz"

  pkg.depends_on "ruby"
  pkg.depends_on "ruby-stomp"

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

  pkg.install_with do
    ["#{settings[:bindir]}/ruby install.rb --plugindir=#{settings[:prefix]}/mcollective/plugins --configdir=#{settings[:sysconfdir]} --sitelibdir=#{settings[:ruby_vendordir]} --configs --quick --man --mandir=#{settings[:mandir]}",
     install]
  end
end
