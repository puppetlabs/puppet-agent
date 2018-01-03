component "marionette-collective" do |pkg, settings, platform|
  pkg.load_from_json("configs/components/marionette-collective.json")

  pkg.build_requires "puppet-runtime" # Provides ruby and ruby-stomp

  # Here we replace and provide mcollective 3 to ensure that even as we continue
  # to release 2.x versions of mcollective upgrades to puppet-agent will be clean
  pkg.replaces 'mcollective', '3.0.0'
  pkg.replaces 'mcollective-common', '3.0.0'
  pkg.replaces 'mcollective-client', '3.0.0'

  pkg.provides 'mcollective', '3.0.0'
  pkg.provides 'mcollective-common', '3.0.0'
  pkg.provides 'mcollective-client', '3.0.0'

  pkg.replaces 'pe-mcollective'
  pkg.replaces 'pe-mcollective-common'
  pkg.replaces 'pe-mcollective-client'

  if platform.is_deb?
    pkg.replaces 'mcollective-doc'
  end

  case platform.servicetype
  when "systemd"
    pkg.install_service "ext/aio/redhat/mcollective.service", "ext/aio/redhat/mcollective.sysconfig", "mcollective"
    pkg.install_file "ext/aio/redhat/mcollective-systemd.logrotate", "/etc/logrotate.d/mcollective"
  when "sysv"
    if platform.is_deb?
      pkg.install_service "ext/aio/debian/mcollective.init", "ext/aio/debian/mcollective.default", "mcollective"
    elsif platform.is_sles?
      pkg.install_service "ext/aio/suse/mcollective.init", "ext/aio/redhat/mcollective.sysconfig", "mcollective"
    elsif platform.is_rpm?
      pkg.install_service "ext/aio/redhat/mcollective.init", "ext/aio/redhat/mcollective.sysconfig", "mcollective"
    end
    pkg.install_file "ext/aio/redhat/mcollective-sysv.logrotate", "/etc/logrotate.d/mcollective"
  when "launchd"
    pkg.install_service "ext/aio/osx/mcollective.plist", nil, "com.puppetlabs.mcollective"
  when "smf"
    pkg.install_service "ext/aio/solaris/smf/mcollective.xml", nil, "mcollective", service_type: "network"
  when "aix"
    pkg.install_service "resources/aix/mcollective.service", nil, "mcollective"
  when "windows"
    # Note - this definition indicates that the file should be filtered out from the Wix
    # harvest. A corresponding service definition file is also required in resources/windows/wix
    pkg.install_service "SourceDir\\#{settings[:base_dir]}\\#{settings[:company_id]}\\#{settings[:product_id]}\\sys\\ruby\\bin\\rubyw.exe"
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
          #{puppet_bin} resource service mcollective > #{service_statefile} || :
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

  if platform.is_windows?
    configdir = File.join(settings[:sysconfdir], 'mcollective', 'etc')
    plugindir = File.join(settings[:sysconfdir], 'mcollective', 'plugins')
  else
    configdir = File.join(settings[:sysconfdir], 'mcollective')
    plugindir = File.join(settings[:install_root], 'mcollective', 'plugins')
  end

  flags = " --bindir=#{settings[:bindir]} \
            --sbindir=#{settings[:bindir]} \
            --sitelibdir=#{settings[:ruby_vendordir]} \
            --ruby=#{File.join(settings[:bindir], 'ruby')} "

  if platform.is_windows?
    pkg.add_source("file://resources/files/windows/mco.bat")
    pkg.install_file "../mco.bat", "#{settings[:link_bindir]}/mco.bat"
    flags = " --bindir=#{settings[:mco_bindir]} \
              --sbindir=#{settings[:mco_bindir]} \
              --sitelibdir=#{settings[:mco_libdir]} \
              --no-service-files \
              --ruby=#{File.join(settings[:ruby_bindir], 'ruby')} "
  end

  pkg.install do
    ["#{settings[:host_ruby]} install.rb \
        --configdir=#{configdir} \
        --plugindir=#{plugindir} \
        --quick \
        --no-batch-files \
        #{flags}"]
  end

  pkg.directory configdir
  pkg.directory plugindir

  if platform.is_windows?
    pkg.directory File.join(settings[:sysconfdir], 'mcollective', 'var', 'log')
  end

  # Bring in the client.cfg and server.cfg from ext/aio.
  pkg.install_file "ext/aio/common/client.cfg.dist", File.join(configdir, 'client.cfg')
  pkg.install_file "ext/aio/common/server.cfg.dist", File.join(configdir, 'server.cfg')

  pkg.configfile File.join(configdir, 'client.cfg')
  pkg.configfile File.join(configdir, 'server.cfg')
  pkg.configfile File.join(configdir, 'facts.yaml')
  pkg.configfile "/etc/logrotate.d/mcollective" if platform.is_linux?

  pkg.link "#{settings[:bindir]}/mco", "#{settings[:link_bindir]}/mco" unless platform.is_windows?
end
