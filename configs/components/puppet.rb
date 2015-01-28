component "puppet" do |pkg, settings, platform|
  pkg.load_from_json("configs/components/puppet.json")

  pkg.build_requires "ruby"
  pkg.build_requires "facter"
  pkg.build_requires "hiera"

  case platform.servicetype
  when "systemd"
    pkg.install_service "ext/systemd/puppet.service", "ext/redhat/client.sysconfig"
  when "sysv"
    if platform.is_deb?
      pkg.install_service "ext/debian/puppet.init", "ext/debian/puppet.default"
    elsif platform.is_rpm?
      pkg.install_service "ext/redhat/client.init", "ext/redhat/client.sysconfig"
    end
  else
    fail "need to know where to put service files"
  end

  if platform.is_deb?
    pkg.install_file "ext/debian/puppet.logrotate", "/etc/logrotate.d/puppet"
  elsif platform.is_rpm?
    pkg.install_file "ext/redhat/logrotate", "/etc/logrotate.d/puppet"
  end

  pkg.install do
    [
      "#{settings[:bindir]}/ruby install.rb --configdir=#{settings[:sysconfdir]} --sitelibdir=#{settings[:ruby_vendordir]} --configs --quick --man --mandir=#{settings[:mandir]}",
      "touch #{File.join(settings[:sysconfdir], 'puppet.conf')}"
    ]
  end

  pkg.configfile File.join(settings[:sysconfdir], 'puppet.conf')
  pkg.configfile File.join(settings[:sysconfdir], 'auth.conf')
  pkg.configfile "/etc/logrotate.d/puppet"
end
