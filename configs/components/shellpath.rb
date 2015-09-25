component "shellpath" do |pkg, settings, platform|
  pkg.version "2015-09-18"
  pkg.add_source "file://resources/files/puppet-agent.sh", sum: "f5987a68adf3844ca15ba53813ad6f63"
  pkg.add_source "file://resources/files/puppet-agent.csh", sum: "62b360a7d15b486377ef6c7c6d05e881"
  pkg.install_configfile("./puppet-agent.sh", "/etc/profile.d/puppet-agent.sh")
  pkg.install_configfile("./puppet-agent.csh", "/etc/profile.d/puppet-agent.csh")
end
