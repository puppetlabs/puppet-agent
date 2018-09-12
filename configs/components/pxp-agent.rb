component "pxp-agent" do |pkg, settings, platform|
  pkg.load_from_json('configs/components/pxp-agent.json')

  toolchain = "-DCMAKE_TOOLCHAIN_FILE=/opt/pl-build-tools/pl-build-toolchain.cmake"
  cmake = "/opt/pl-build-tools/bin/cmake"

  if platform.is_windows?
    pkg.environment "PATH", "$(shell cygpath -u #{settings[:prefix]}/lib):$(shell cygpath -u #{settings[:gcc_bindir]}):$(shell cygpath -u #{settings[:ruby_bindir]}):/cygdrive/c/Windows/system32:/cygdrive/c/Windows:/cygdrive/c/Windows/System32/WindowsPowerShell/v1.0"
  else
    pkg.environment "PATH", "#{settings[:bindir]}:/opt/pl-build-tools/bin:$(PATH)"
  end

  if settings[:system_openssl]
    pkg.build_requires "openssl-devel"
  else
    pkg.build_requires "puppet-runtime" # Provides openssl
  end

  pkg.build_requires "leatherman"
  pkg.build_requires "cpp-pcp-client"
  pkg.build_requires "cpp-hocon"

  make = platform[:make]

  special_flags = " -DCMAKE_INSTALL_PREFIX=#{settings[:prefix]} "

  if platform.is_aix?
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-gcc-5.2.0-11.aix#{platform.os_version}.ppc.rpm"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-cmake-3.2.3-2.aix#{platform.os_version}.ppc.rpm"
  elsif platform.is_macos?
    cmake = "/usr/local/bin/cmake"
    toolchain = ""
    special_flags += "-DCMAKE_CXX_FLAGS='#{settings[:cflags]}'"
  elsif platform.is_cross_compiled_linux?
    cmake = "/opt/pl-build-tools/bin/cmake"
    toolchain = "-DCMAKE_TOOLCHAIN_FILE=/opt/pl-build-tools/#{settings[:platform_triple]}/pl-build-toolchain.cmake"
  elsif platform.is_solaris?
    cmake = "/opt/pl-build-tools/i386-pc-solaris2.#{platform.os_version}/bin/cmake"
    toolchain = "-DCMAKE_TOOLCHAIN_FILE=/opt/pl-build-tools/#{settings[:platform_triple]}/pl-build-toolchain.cmake"

    # PCP-87: If we build with -O3, solaris segfaults due to something in std::vector
    special_flags += " -DCMAKE_CXX_FLAGS_RELEASE='-O2 -DNDEBUG' "
  elsif platform.is_windows?
    make = "#{settings[:gcc_bindir]}/mingw32-make"
    pkg.environment "CYGWIN", settings[:cygwin]

    cmake = "C:/ProgramData/chocolatey/bin/cmake.exe -G \"MinGW Makefiles\""
    toolchain = "-DCMAKE_TOOLCHAIN_FILE=#{settings[:tools_root]}/pl-build-toolchain.cmake"
  elsif platform.name =~ /sles-15/
    # These platforms use the default OS toolchain, rather than pl-build-tools
    cmake = "cmake"
    toolchain = ""
    special_flags += " -DCMAKE_CXX_FLAGS='#{settings[:cflags]} -Wno-deprecated -Wimplicit-fallthrough=0' "
  elsif platform.is_cisco_wrlinux?
    special_flags += " -DLEATHERMAN_USE_LOCALES=OFF "
  end

  pkg.configure do
    [
      "#{cmake}\
      #{toolchain} \
          -DLEATHERMAN_GETTEXT=ON \
          -DCMAKE_VERBOSE_MAKEFILE=ON \
          -DCMAKE_PREFIX_PATH=#{settings[:prefix]} \
          -DCMAKE_INSTALL_RPATH=#{settings[:libdir]} \
          -DCMAKE_SYSTEM_PREFIX_PATH=#{settings[:prefix]} \
          -DMODULES_INSTALL_PATH=#{File.join(settings[:install_root], 'pxp-agent', 'modules')} \
          #{special_flags} \
          ."
    ]
  end

  pkg.build do
    ["#{make} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    ["#{make} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install"]
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
    pkg.directory File.join(settings[:sysconfdir], 'pxp-agent', 'modules'), mode: "0755"
    pkg.directory File.join(settings[:install_root], 'pxp-agent', 'spool'), mode: "0750"
    pkg.directory File.join(settings[:install_root], 'pxp-agent', 'tasks-cache'), mode: "0750"
    pkg.directory File.join(settings[:logdir], 'pxp-agent'), mode: "0750"
  end

  case platform.servicetype
  when "systemd"
    pkg.install_service "ext/systemd/pxp-agent.service", "ext/redhat/pxp-agent.sysconfig"
    pkg.install_configfile "ext/systemd/pxp-agent.logrotate", "/etc/logrotate.d/pxp-agent"
    if platform.is_deb?
      pkg.add_postinstall_action ["install"], ["systemctl disable pxp-agent.service >/dev/null || :"]
    end
  when "sysv"
    if platform.is_deb?
      pkg.install_service "ext/debian/pxp-agent.init", "ext/debian/pxp-agent.default"
      pkg.add_postinstall_action ["install"], ["update-rc.d pxp-agent disable > /dev/null || :"]
    elsif platform.is_sles?
      pkg.install_service "ext/suse/pxp-agent.init", "ext/redhat/pxp-agent.sysconfig"
    elsif platform.is_rpm?
      pkg.install_service "ext/redhat/pxp-agent.init", "ext/redhat/pxp-agent.sysconfig"
    end
    pkg.install_configfile "ext/pxp-agent.logrotate", "/etc/logrotate.d/pxp-agent"
  when "launchd"
    pkg.install_service "ext/osx/pxp-agent.plist", nil, "com.puppetlabs.pxp-agent"
  when "smf"
    pkg.install_service "ext/solaris/smf/pxp-agent.xml", service_type: "network"
  when "aix"
    pkg.install_service "resources/aix/pxp-agent.service", nil, "pxp-agent"
  when "windows"
    # Note - this definition indicates that the file should be filtered out from the Wix
    # harvest. A corresponding service definition file is also required in resources/windows/wix
    pkg.install_service "SourceDir\\#{settings[:base_dir]}\\#{settings[:company_id]}\\#{settings[:product_id]}\\puppet\\bin\\nssm.exe"
  else
    fail "need to know where to put #{pkg.get_name} service files"
  end
end
