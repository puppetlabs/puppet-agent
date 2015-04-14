component "puppet" do |pkg, settings, platform|
  pkg.load_from_json("configs/components/puppet.json")

  pkg.build_requires "ruby"
  pkg.build_requires "facter"
  pkg.build_requires "hiera"

  pkg.replaces 'puppet', '4.0.0'
  pkg.provides 'puppet', '4.0.0'
  pkg.replaces 'pe-puppet', '4.0.0'
  pkg.provides 'pe-puppet', '4.0.0'
  pkg.replaces 'pe-ruby-rgen'
  pkg.replaces 'pe-cloud-provisioner-libs'
  pkg.replaces 'pe-cloud-provisioner'
  pkg.replaces 'pe-puppet-enterprise-release'
  pkg.provides 'pe-puppet-enterprise-release'
  pkg.replaces 'pe-agent'
  pkg.provides 'pe-agent'

  if platform.is_deb?
    pkg.replaces 'puppet-common', '4.0.0'
    pkg.provides 'puppet-common', '4.0.0'
    pkg.replaces 'pe-puppet-common', '4.0.0'
    pkg.provides 'pe-puppet-common', '4.0.0'
  end

  case platform.servicetype
  when "systemd"
    pkg.install_service "ext/systemd/puppet.service", "ext/redhat/client.sysconfig"
  when "sysv"
    if platform.is_deb?
      pkg.install_service "ext/debian/puppet.init", "ext/debian/puppet.default"
    elsif platform.is_sles?
      pkg.install_service "ext/suse/client.init", "ext/redhat/client.sysconfig"
    elsif platform.is_rpm?
      pkg.install_service "ext/redhat/client.init", "ext/redhat/client.sysconfig"
    end
  else
    fail "need to know where to put service files"
  end

  pkg.install do
    "#{settings[:bindir]}/ruby install.rb --configdir=#{settings[:puppet_configdir]} --sitelibdir=#{settings[:ruby_vendordir]} --configs --quick --man --mandir=#{settings[:mandir]}"
  end

  pkg.configfile File.join(settings[:puppet_configdir], 'puppet.conf')
  pkg.configfile File.join(settings[:puppet_configdir], 'auth.conf')

  pkg.directory File.join(settings[:prefix], 'cache'), mode: '0750'
  pkg.directory settings[:puppet_configdir]
  pkg.directory settings[:puppet_codedir]
  pkg.directory File.join(settings[:puppet_codedir], "modules")
  pkg.directory File.join(settings[:prefix], "modules")
  pkg.directory File.join(settings[:puppet_codedir], 'environments')
  pkg.directory File.join(settings[:puppet_codedir], 'environments', 'production')
  pkg.directory File.join(settings[:puppet_codedir], 'environments', 'production', 'manifests')
  pkg.directory File.join(settings[:puppet_codedir], 'environments', 'production', 'modules')
  pkg.install_configfile 'conf/environment.conf', File.join(settings[:puppet_codedir], 'environments', 'production', 'environment.conf')
  pkg.directory File.join(settings[:logdir], 'puppet'), mode: "0750"

  pkg.link "#{settings[:bindir]}/puppet", "#{settings[:link_bindir]}/puppet"
end
