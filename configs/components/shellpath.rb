component "shellpath" do |pkg, settings, platform|
  pkg.version "2015-09-18"
  pkg.add_source "file://resources/files/puppet-agent.sh", sum: "f5987a68adf3844ca15ba53813ad6f63"
  pkg.add_source "file://resources/files/puppet-agent.csh", sum: "62b360a7d15b486377ef6c7c6d05e881"
  pkg.install_file("./puppet-agent.sh", "/etc/profile.d/puppet-agent.sh")

  # The cisco platforms have non-standard packages for /etc/profile.d and also try to run the csh
  if platform.name =~ /cisco-wrlinux-5/
    pkg.requires 'platform'
    # cisco-wrlinux-5 has a bug that requires profile.d scripts to be executable
    pkg.install_file("./puppet-agent.sh", "/etc/profile.d/puppet-agent.sh", mode: '0755')
  elsif platform.name =~ /cisco-wrlinux-7/
    pkg.requires 'cisco-config'
  else
    pkg.install_file("./puppet-agent.csh", "/etc/profile.d/puppet-agent.csh")
  end
end
