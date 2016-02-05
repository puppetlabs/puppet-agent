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
    if platform.is_rpm?
      puppet_bin = "/opt/puppetlabs/bin/puppet"
      rpm_statedir = "%{_localstatedir}/lib/rpm-state/#{pkg.get_name}"
      service_statefile = "#{rpm_statedir}/service.pp"
      pkg.add_preinstall_action ["upgrade"],
        [<<-HERE.undent
          install --owner root --mode 0700 --directory #{rpm_statedir} || :
          if [ -x #{puppet_bin} ] ; then
            #{puppet_bin} resource service puppet > #{service_statefile} || :
          fi
          HERE
        ]

      pkg.add_postinstall_action ["upgrade"],
        [<<-HERE.undent
          if [ -f #{service_statefile} ] ; then
            #{puppet_bin} apply #{service_statefile} > /dev/null 2>&1 || :
            rm -rf #{rpm_statedir} || :
          fi
          HERE
        ]
    end
  when "launchd"
    pkg.install_service "ext/osx/puppet.plist", nil, "com.puppetlabs.puppet"
  when "smf"
    pkg.install_service "ext/solaris/smf/puppet.xml", "ext/solaris/smf/puppet", service_type: "network"
  when "aix"
    pkg.install_service "resources/aix/puppet.service", nil, "puppet"
  when "windows"
    puts "Service files not enabled on windows"
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

  # Puppet requires tar, otherwise PMT will not install modules
  if platform.is_solaris?
    if platform.os_version == "11"
      pkg.requires 'archiver/gnu-tar'
    end
  else
    # PMT doesn't work on AIX, don't add a useless dependency
    # We will need to revisit when we update PMT support
    pkg.requires 'tar' unless platform.is_aix?
  end

  if platform.is_osx?
    pkg.add_source("file://resources/files/osx_paths.txt", sum: "077ceb5e2f71cf733190a61d2fd221fb")
    pkg.install_file("../osx_paths.txt", "/etc/paths.d/puppet-agent")
  end

  if platform.is_windows?
    pkg.environment "FACTERDIR" => settings[:prefix]
  end

  pkg.install do
    [
      "#{settings[:host_ruby]} install.rb \
        --ruby=#{File.join(settings[:bindir], 'ruby')} \
        --check-prereqs \
        --bindir=#{settings[:bindir]} \
        --configdir=#{settings[:puppet_configdir]} \
        --sitelibdir=#{settings[:ruby_vendordir]} \
        --codedir=#{settings[:puppet_codedir]} \
        --vardir=#{File.join(settings[:prefix], 'cache')} \
        --rundir=#{settings[:piddir]} \
        --logdir=#{settings[:logdir]} \
        --configs \
        --quick \
        --man \
        --mandir=#{settings[:mandir]}"
    ]
  end

  #The following will add the vim syntax files for puppet
  #in the /opt/puppetlabs/puppet/share/vim directory
  pkg.add_source "file://resources/files/ftdetect/ftdetect_puppet.vim", sum: "9e93cd63787de6b9ed458c95061f06eb"
  pkg.add_source "file://resources/files/ftplugin/ftplugin_puppet.vim", sum: "0fde61360edf2bb205947f768bfb2d57"
  pkg.add_source "file://resources/files/indent/indent_puppet.vim", sum: "4bc2dee4c9c4e74aa3103339ad3ab227"
  pkg.add_source "file://resources/files/syntax/syntax_puppet.vim", sum: "3ef904628c734af25fe673638c4e0b3d"

  pkg.install_configfile("../ftdetect_puppet.vim", "#{settings[:datadir]}/vim/puppet-vimfiles/ftdetect/puppet.vim")
  pkg.install_configfile("../ftplugin_puppet.vim", "#{settings[:datadir]}/vim/puppet-vimfiles/ftplugin/puppet.vim")
  pkg.install_configfile("../indent_puppet.vim", "#{settings[:datadir]}/vim/puppet-vimfiles/indent/puppet.vim")
  pkg.install_configfile("../syntax_puppet.vim", "#{settings[:datadir]}/vim/puppet-vimfiles/syntax/puppet.vim")

  pkg.install_file ".gemspec", "#{settings[:gem_home]}/specifications/#{pkg.get_name}.gemspec"

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

  pkg.link "#{settings[:bindir]}/puppet", "#{settings[:link_bindir]}/puppet" unless platform.is_windows?
  if platform.is_eos?
    pkg.link "#{settings[:sysconfdir]}", "#{settings[:link_sysconfdir]}"
  end
end
