component "puppet" do |pkg, settings, platform|
#  pkg.fetch_source "http://builds.puppetlabs.lan/pe-puppet/3.7.2.0/artifacts/pe-puppet-3.7.2.0.tar.gz", "f875da5680101b9550f866009f18d0ef"
  pkg.url = "http://builds.puppetlabs.lan/pe-puppet/3.7.2.0/artifacts/pe-puppet-3.7.2.0.tar.gz"
  pkg.md5sum = "f875da5680101b9550f866009f18d0ef"
  pkg.version = "3.7.2.0"
  # pkg.load_metadata
  # puppet.json
  # { "url": "http://...", "md5sum": "abcd1234", "version": "3.7.2.0" }

  pkg.depends_on "ruby"
  pkg.depends_on "facter"
  pkg.depends_on "hiera"

  case platform[:servicetype]
  when "systemd"
    pkg.add_service_file "#{platform[:servicedir]}/puppet.service"
    pkg.add_service_file "#{platform[:defaultdir]}/puppet"
    install = ["cp -pr ext/systemd/pe-puppet.service #{platform[:servicedir]}/puppet.service",
               "touch #{platform[:defaultdir]}/puppet"]
  when "sysv"
    pkg.add_service_file "#{platform[:servicedir]}/puppet"
    pkg.add_service_file "#{platform[:defaultdir]}/puppet"
    install = ["cp -pr ext/redhat/pe-puppet-client.init #{platform[:servicedir]}/puppet",
               "touch #{platform[:defaultdir]}/puppet"]
  else
    fail "need to know where to put service files"
  end

  pkg.install_with do
    ["#{settings[:bindir]}/ruby install.rb --configdir=#{settings[:sysconfdir]} --sitelibdir=#{settings[:ruby_vendordir]} --configs --quick --man --mandir=#{settings[:mandir]}",
     install]
  end
end
