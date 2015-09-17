component "puppet" do |pkg, settings, platform|
  pkg.load_from_json("configs/components/puppet.json")

  pkg.build_requires "ruby"
  pkg.build_requires "facter"
  pkg.build_requires "hiera"

  pkg.replaces 'puppet', '4.0.0'
  pkg.provides 'puppet', '4.0.0'

  pkg.replaces 'pe-puppet'
  pkg.replaces 'pe-ruby-rgen'
  pkg.replaces 'pe-cloud-provisioner-libs'
  pkg.replaces 'pe-cloud-provisioner'
  pkg.replaces 'pe-puppet-enterprise-release', '4.0.0'
  pkg.replaces 'pe-agent'

  if platform.is_deb?
    pkg.replaces 'puppet-common', '4.0.0'
    pkg.provides 'puppet-common', '4.0.0'
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
  when "launchd"
    pkg.install_service "ext/osx/puppet.plist", nil, "com.puppetlabs.puppet"
  when "smf"
    pkg.install_service "ext/solaris/smf/puppet.xml", "ext/solaris/smf/puppet"
  when "aix"
    pkg.install_service "resources/aix/puppet.service", nil, "puppet"
  else
    fail "need to know where to put service files"
  end

  # To create a tmpfs directory for the piddir, it seems like it's either this
  # or a PR against Puppet until that sort of support can be rolled into the
  # Vanagon tooling directly. It's totally a hack, and I'm not proud of this
  # in any meaningful way.
  # - Ryan "I'm sorry. I'm so sorry." McKern, June 8 2015
  # - Jira # RE-3954
  if platform.servicetype == 'systemd'
    pkg.build do
      "echo 'd #{settings[:piddir]} 0755 root root -' > puppet-agent.conf"
    end

    # Also part of the ugly, ugly, ugly, sad, tragic hack.
    # - Ryan "Rub some HEREDOC on it" McKern, June 8 2015
    # - Jira # RE-3954
    pkg.install_configfile 'puppet-agent.conf', File.join(settings[:tmpfilesdir], 'puppet-agent.conf')
  end

  if platform.architecture == "sparc"
    ruby = '/opt/csw/bin/ruby'
  else
    ruby = File.join(settings[:bindir], 'ruby')
  end

  # Puppet requires tar, otherwise PMT will not install modules
  if platform.is_solaris?
    if platform.os_version == "11"
      pkg.requires 'archiver/gnu-tar'
    end
  else
    pkg.requires 'tar'
  end

  pkg.install do
    [
      "#{ruby} install.rb --ruby=#{File.join(settings[:bindir], 'ruby')} --no-check-prereqs --bindir=#{settings[:bindir]} --configdir=#{settings[:puppet_configdir]} --sitelibdir=#{settings[:ruby_vendordir]} --configs --quick --man --mandir=#{settings[:mandir]}",
    ]
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
