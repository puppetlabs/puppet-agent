component "puppet" do |pkg, settings, platform|
  pkg.load_from_json("configs/components/puppet.json")

  pkg.build_requires "puppet-runtime" # Provides ruby and rubygem-win32-dir
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
  pkg.replaces 'pe-puppetserver-common', '4.0.0'

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
    pkg.install_service "ext/solaris/smf/puppet.xml", "ext/solaris/smf/puppet", service_type: "network"
  when "aix"
    pkg.install_service "resources/aix/puppet.service", nil, "puppet"
  when "windows"
    # Note - this definition indicates that the file should be filtered out from the Wix
    # harvest. A corresponding service definition file is also required in resources/windows/wix
    pkg.install_service "SourceDir\\#{settings[:base_dir]}\\#{settings[:company_id]}\\#{settings[:product_id]}\\sys\\ruby\\bin\\ruby.exe"
  else
    fail "need to know where to put service files"
  end

  if (platform.servicetype == "sysv" && platform.is_rpm?) || platform.is_aix?
    puppet_bin = "/opt/puppetlabs/bin/puppet"
    rpm_statedir = "%{_localstatedir}/lib/rpm-state/#{pkg.get_name}"
    service_statefile = "#{rpm_statedir}/service.pp"
    pkg.add_preinstall_action ["upgrade"],
      [<<-HERE.undent
        mkdir -p  #{rpm_statedir} && chown root #{rpm_statedir} && chmod 0700 #{rpm_statedir} || :
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

  if platform.is_macos?
    pkg.add_source("file://resources/files/osx_paths.txt", sum: "077ceb5e2f71cf733190a61d2fd221fb")
    pkg.install_file("../osx_paths.txt", "/etc/paths.d/puppet-agent")
  end

  if platform.is_windows?
    pkg.environment "FACTERDIR", settings[:facter_root]
    pkg.environment "PATH", "$(shell cygpath -u #{settings[:gcc_bindir]}):$(shell cygpath -u #{settings[:ruby_bindir]}):$(shell cygpath -u #{settings[:bindir]}):/cygdrive/c/Windows/system32:/cygdrive/c/Windows:/cygdrive/c/Windows/System32/WindowsPowerShell/v1.0"
    pkg.environment "RUBYLIB", "#{settings[:hiera_libdir]};#{settings[:facter_root]}/lib"
  end

  if platform.is_windows?
    vardir = File.join(settings[:sysconfdir], 'puppet', 'cache')
    configdir = File.join(settings[:sysconfdir], 'puppet', 'etc')
    logdir = File.join(settings[:sysconfdir], 'puppet', 'var', 'log')
    piddir = File.join(settings[:sysconfdir], 'puppet', 'var', 'run')
    prereqs = "--check-prereqs"
  else
    vardir = File.join(settings[:prefix], 'cache')
    configdir = settings[:puppet_configdir]
    logdir = settings[:logdir]
    piddir = settings[:piddir]
    prereqs = "--no-check-prereqs"
  end
  pkg.install do
    [
      "#{settings[:host_ruby]} install.rb \
        --ruby=#{File.join(settings[:bindir], 'ruby')} \
        #{prereqs} \
        --bindir=#{settings[:bindir]} \
        --configdir=#{configdir} \
        --sitelibdir=#{settings[:ruby_vendordir]} \
        --codedir=#{settings[:puppet_codedir]} \
        --vardir=#{vardir} \
        --rundir=#{piddir} \
        --logdir=#{logdir} \
        --localedir=#{settings[:datadir]}/locale \
        --configs \
        --quick \
        --no-batch-files \
        --man \
        --mandir=#{settings[:mandir]}",]
  end

  if platform.is_windows?
    pkg.install do
      ["/usr/bin/cp #{settings[:prefix]}/VERSION #{settings[:install_root]}",]
    end
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

  if platform.is_windows?
    # Install the appropriate .batch files to the INSTALLDIR/bin directory
    pkg.add_source("file://resources/files/windows/environment.bat", sum: "810195e5fe09ce1704d0f1bf818b2d9a")
    pkg.add_source("file://resources/files/windows/puppet.bat", sum: "002618e115db9fd9b42ec611e1ec70d2")
    pkg.add_source("file://resources/files/windows/puppet_interactive.bat", sum: "4b40eb0df91d2ca8209302062c4940c4")
    pkg.add_source("file://resources/files/windows/puppet_shell.bat", sum: "24477c6d2c0e7eec9899fb928204f1a0")
    pkg.add_source("file://resources/files/windows/run_puppet_interactive.bat", sum: "d4ae359425067336e97e4e3a200027d5")
    pkg.install_file "../environment.bat", "#{settings[:link_bindir]}/environment.bat"
    pkg.install_file "../puppet.bat", "#{settings[:link_bindir]}/puppet.bat"
    pkg.install_file "../puppet_interactive.bat", "#{settings[:link_bindir]}/puppet_interactive.bat"
    pkg.install_file "../run_puppet_interactive.bat", "#{settings[:link_bindir]}/run_puppet_interactive.bat"
    pkg.install_file "../puppet_shell.bat", "#{settings[:link_bindir]}/puppet_shell.bat"

    pkg.install_file "ext/windows/service/daemon.bat", "#{settings[:bindir]}/daemon.bat"
    pkg.install_file "ext/windows/service/daemon.rb", "#{settings[:service_dir]}/daemon.rb"
    pkg.install_file "../wix/icon/puppet.ico", "#{settings[:miscdir]}/puppet.ico"
    pkg.install_file "../wix/license/LICENSE.rtf", "#{settings[:miscdir]}/LICENSE.rtf"
    pkg.directory settings[:service_dir]
  end

  pkg.configfile File.join(configdir, 'puppet.conf')
  pkg.configfile File.join(configdir, 'auth.conf')

  pkg.directory vardir, mode: '0750'
  pkg.directory configdir
  pkg.directory File.join(settings[:datadir], "locale")
  pkg.directory settings[:puppet_codedir]
  pkg.directory File.join(settings[:puppet_codedir], "modules")
  pkg.directory File.join(settings[:prefix], "modules")
  pkg.directory File.join(settings[:puppet_codedir], 'environments')
  pkg.directory File.join(settings[:puppet_codedir], 'environments', 'production')
  pkg.directory File.join(settings[:puppet_codedir], 'environments', 'production', 'manifests')
  pkg.directory File.join(settings[:puppet_codedir], 'environments', 'production', 'modules')
  pkg.install_configfile 'conf/environment.conf', File.join(settings[:puppet_codedir], 'environments', 'production', 'environment.conf')

  if platform.is_windows?
    pkg.directory File.join(settings[:sysconfdir], 'puppet', 'var', 'log')
    pkg.directory File.join(settings[:sysconfdir], 'puppet', 'var', 'run')
  else
    pkg.directory File.join(settings[:logdir], 'puppet'), mode: "0750"
  end

  pkg.link "#{settings[:bindir]}/puppet", "#{settings[:link_bindir]}/puppet" unless platform.is_windows?
  if platform.is_eos?
    pkg.link "#{settings[:sysconfdir]}", "#{settings[:link_sysconfdir]}"
  end
end
