component "marionette-collective" do |pkg, settings, platform|
  pkg.load_from_json("configs/components/marionette-collective.json")

  pkg.build_requires "ruby"
  pkg.build_requires "ruby-stomp"

  pkg.replaces 'mcollective', '2.9.0'
  pkg.replaces 'mcollective-common', '2.9.0'
  pkg.replaces 'mcollective-client', '2.9.0'

  pkg.provides 'mcollective', '2.9.0'
  pkg.provides 'mcollective-common', '2.9.0'
  pkg.provides 'mcollective-client', '2.9.0'

  if platform.is_deb?
    pkg.replaces 'mcollective-doc'
  end

  case platform.servicetype
  when "systemd"
    pkg.install_service "ext/aio/redhat/mcollective.service", "ext/aio/redhat/mcollective.sysconfig", "mcollective"
    pkg.install_file "ext/aio/redhat/mcollective-systemd.logrotate", "/etc/logrotate.d/mcollective"
  when "sysv"
    if platform.is_deb?
      pkg.install_service "ext/aio/debian/mcollective.init", "ext/aio/debian/mcollective.default", "mcollective"
    elsif platform.is_sles?
      pkg.install_service "ext/aio/suse/mcollective.init", "ext/aio/redhat/mcollective.sysconfig"
    elsif platform.is_rpm?
      pkg.install_service "ext/aio/redhat/mcollective.init", "ext/aio/redhat/mcollective.sysconfig", "mcollective"
    end

    pkg.install_file "ext/aio/redhat/mcollective-sysv.logrotate", "/etc/logrotate.d/mcollective"

  else
    fail "need to know where to put service files"
  end

  pkg.install do
    ["#{settings[:bindir]}/ruby install.rb --configdir=#{File.join(settings[:sysconfdir], 'mcollective')} --sitelibdir=#{settings[:ruby_vendordir]} --quick --sbindir=#{settings[:bindir]}"]
  end

  pkg.directory File.join(settings[:sysconfdir], "mcollective")

  # Bring in the client.cfg and server.cfg from ext/aio.
  pkg.install_file "ext/aio/common/client.cfg.dist", File.join(settings[:sysconfdir], 'mcollective', 'client.cfg')
  pkg.install_file "ext/aio/common/server.cfg.dist", File.join(settings[:sysconfdir], 'mcollective', 'server.cfg')

  pkg.configfile File.join(settings[:sysconfdir], 'mcollective', 'client.cfg')
  pkg.configfile File.join(settings[:sysconfdir], 'mcollective', 'server.cfg')
  pkg.configfile File.join(settings[:sysconfdir], 'mcollective', 'facts.yaml')
  pkg.configfile "/etc/logrotate.d/mcollective"

  pkg.link "#{settings[:bindir]}/mco", "#{settings[:link_bindir]}/mco"
end
