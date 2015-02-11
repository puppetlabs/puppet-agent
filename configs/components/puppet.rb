component "puppet" do |pkg, settings, platform|
  pkg.load_from_json("configs/components/puppet.json")

  pkg.build_requires "ruby"
  pkg.build_requires "facter"
  pkg.build_requires "hiera"

  pkg.replaces 'puppet'

  if platform.is_deb?
    pkg.replaces 'puppet-common'
  end

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
    "#{settings[:bindir]}/ruby install.rb --puppetdir=#{settings[:puppetdir]} --sitelibdir=#{settings[:ruby_vendordir]} --configs --quick --man --mandir=#{settings[:mandir]}"
  end

  pkg.configfile File.join(settings[:puppet_configdir], 'puppet.conf')
  pkg.configfile File.join(settings[:puppet_configdir], 'auth.conf')
  pkg.configfile "/etc/logrotate.d/puppet"

  pkg.directory File.join(settings[:prefix], 'cache'), mode: '0750'
  pkg.directory File.join(settings[:puppetdir], 'ssl'), mode: '0750'
  pkg.directory settings[:puppet_configdir]
  pkg.directory settings[:puppet_codedir]

  # PUP-2037 - Ensure the package creates the default environment for directory environments
  # Being deliberately explicit below ensures that the component/package will own each of these directories.
  pkg.directory File.join(settings[:puppet_codedir], 'environments')
  pkg.directory File.join(settings[:puppet_codedir], 'environments', 'production')
  pkg.directory File.join(settings[:puppet_codedir], 'environments', 'production', 'manifests')
  pkg.directory File.join(settings[:puppet_codedir], 'environments', 'production', 'modules')
end
