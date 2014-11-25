component "puppet" do |pkg, settings, platform|
  pkg.url "http://builds.puppetlabs.lan/pe-puppet/3.7.2.2/artifacts/pe-puppet-3.7.2.2.tar.gz"
  pkg.md5sum "4f0c81833af80aee77b45335b7e69a7f"
  pkg.version "3.7.2.2"

  pkg.build_requires "ruby"
  pkg.build_requires "facter"
  pkg.build_requires "hiera"

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

  pkg.install do
    ["#{settings[:bindir]}/ruby install.rb --configdir=#{settings[:sysconfdir]} --sitelibdir=#{settings[:ruby_vendordir]} --configs --quick --man --mandir=#{settings[:mandir]}",
     install]
  end
end
