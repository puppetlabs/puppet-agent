component "pxp-agent" do |pkg, settings, platform|
  unless settings[:pxp_agent_version] && settings[:pxp_agent_location] && settings[:pxp_agent_basename]
    raise "Expected to find :pxp_agent_version, :pxp_agent_location, and :pxp_agent_basename settings; Please set these in your project file before including pxp-agent as a component."
  end

  pkg.version settings[:pxp_agent_version]

  tarball_name = "#{settings[:pxp_agent_basename]}.tar.gz"
  pkg.url File.join(settings[:pxp_agent_location], tarball_name)
  pkg.sha1sum File.join(settings[:pxp_agent_location], "#{tarball_name}.sha1")

  pkg.install_only true

  if platform.is_windows?
    # We need to make sure we're setting permissions correctly for the executables
    # in the ruby bindir since preserving permissions in archives in windows is
    # ... weird, and we need to be able to use cygwin environment variable use
    # so cmd.exe was not working as expected.
    install_command = [
      "gunzip -c #{tarball_name} | tar --skip-old-files -C /cygdrive/c/ -xf -",
      "chmod 755 #{settings[:bindir].sub('C:', '/cygdrive/c')}/*"
    ]
  elsif platform.is_macos?
    # We can't untar into '/' because of SIP on macOS; Just copy the contents
    # of these directories instead:
    install_command = [
      "tar -xzf #{tarball_name}",
      "for d in opt var private; do rsync -ka --ignore-existing \"$${d}/\" \"/$${d}/\"; done"
    ]
  elsif platform.is_aix? || platform.is_solaris?
    install_command = ["gunzip -c #{tarball_name} | #{platform.tar} -C / -xf -"]
  else
    install_command = ["gunzip -c #{tarball_name} | #{platform.tar} --skip-old-files -C / -xf -"]
  end

  pkg.install do
    install_command
  end

  pkg.directory File.join(settings[:sysconfdir], 'pxp-agent')
  if platform.is_windows?
    pkg.directory File.join(settings[:sysconfdir], 'pxp-agent', 'modules')
    pkg.directory File.join(settings[:install_root], 'pxp-agent', 'spool')
    pkg.directory File.join(settings[:install_root], 'pxp-agent', 'tasks-cache')
    pkg.directory File.join(settings[:sysconfdir], 'pxp-agent', 'log')
  else
    # Output directories (spool, tasks-cache, logdir) are restricted to root agent.
    # Modules is left readable so non-root agents can also use the installed modules.
    pkg.directory File.join(settings[:sysconfdir], 'pxp-agent', 'modules'), mode: '0755'
    pkg.directory File.join(settings[:install_root], 'pxp-agent', 'spool'), mode: '0750'
    pkg.directory File.join(settings[:install_root], 'pxp-agent', 'tasks-cache'), mode: '0750'
    pkg.directory File.join(settings[:logdir], 'pxp-agent'), mode: '0750'
  end

  if platform.is_windows?
    # Copy the boost dlls into the bindir
    settings[:boost_libs].each do |name|
      pkg.install_file "#{settings[:prefix]}/lib/libboost_#{name}.dll",   "#{settings[:bindir]}/libboost_#{name}.dll"
      pkg.install_file "#{settings[:prefix]}/lib/libboost_#{name}.dll.a", "#{settings[:bindir]}/libboost_#{name}.dll.a"
    end
  end

  service_conf = settings[:service_conf]

  platform.get_service_types.each do |servicetype|
    case servicetype
    when 'systemd'
      pkg.install_service "#{service_conf}/systemd/pxp-agent.service", "#{service_conf}/redhat/pxp-agent.sysconfig", init_system: servicetype
      pkg.install_configfile "#{service_conf}/systemd/pxp-agent.logrotate", '/etc/logrotate.d/pxp-agent'
      if platform.is_deb?
        pkg.add_postinstall_action ["install"], ["if [ -f '/proc/1/comm' ]; then init_comm=`cat /proc/1/comm`;  if [ \"$init_comm\" == \"systemd\" ]; then systemctl disable pxp-agent.service >/dev/null || :; fi; fi"]
      end
    when 'sysv'
      if platform.is_deb?
        pkg.install_service "#{service_conf}/debian/pxp-agent.init", "#{service_conf}/debian/pxp-agent.default", init_system: servicetype
        pkg.add_postinstall_action ["install"], ["if [ -f '/proc/1/comm' ]; then init_comm=`cat /proc/1/comm`;  if [ \"$init_comm\" == \"init\" ]; then update-rc.d pxp-agent disable > /dev/null || :; fi; fi"]
      elsif platform.is_sles?
        pkg.install_service "#{service_conf}/suse/pxp-agent.init", "#{service_conf}/redhat/pxp-agent.sysconfig", init_system: servicetype
      elsif platform.is_rpm?
        pkg.install_service "#{service_conf}/redhat/pxp-agent.init", "#{service_conf}/redhat/pxp-agent.sysconfig", init_system: servicetype
      end
      pkg.install_configfile "#{service_conf}/pxp-agent.logrotate", '/etc/logrotate.d/pxp-agent'
    when 'launchd'
      pkg.install_service "#{service_conf}/osx/pxp-agent.plist", nil, 'com.puppetlabs.pxp-agent', init_system: servicetype
      pkg.install_configfile "#{service_conf}/osx/pxp-agent.newsyslog.conf", '/etc/newsyslog.d/com.puppetlabs.pxp-agent.conf'
    when 'smf'
      pkg.install_service "#{service_conf}/solaris/smf/pxp-agent.xml", service_type: 'network', init_system: servicetype
    when 'aix'
      pkg.install_service 'resources/aix/pxp-agent.service', nil, 'pxp-agent', init_system: servicetype
    when 'windows'
      # Note - this definition indicates that the file should be filtered out from the Wix
      # harvest. A corresponding service definition file is also required in resources/windows/wix
      pkg.install_service "SourceDir\\#{settings[:base_dir]}\\#{settings[:company_id]}\\#{settings[:product_id]}\\puppet\\bin\\nssm-pxp-agent.exe", init_system: servicetype
    else
      fail "need to know where to put #{pkg.get_name} service files"
    end
  end
end
