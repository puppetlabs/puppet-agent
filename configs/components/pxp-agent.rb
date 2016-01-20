component "pxp-agent" do |pkg, settings, platform|
  pkg.load_from_json('configs/components/pxp-agent.json')

  toolchain = "-DCMAKE_TOOLCHAIN_FILE=/opt/pl-build-tools/pl-build-toolchain.cmake"
  cmake = "/opt/pl-build-tools/bin/cmake"

  unless platform.is_windows?
    pkg.environment "PATH" => "#{settings[:bindir]}:/opt/pl-build-tools/bin:$$PATH"
  end

  pkg.build_requires "openssl"
  pkg.build_requires "leatherman"
  pkg.build_requires "cpp-pcp-client"

  make = platform[:make]

  if platform.is_aix?
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-gcc-5.2.0-1.aix#{platform.os_version}.ppc.rpm"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-cmake-3.2.3-2.aix#{platform.os_version}.ppc.rpm"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-boost-1.58.0-1.aix#{platform.os_version}.ppc.rpm"
  elsif platform.is_osx?
    cmake = "/usr/local/bin/cmake"
    toolchain = ""
  elsif platform.is_solaris?
    cmake = "/opt/pl-build-tools/i386-pc-solaris2.#{platform.os_version}/bin/cmake"
    toolchain = "-DCMAKE_TOOLCHAIN_FILE=/opt/pl-build-tools/#{settings[:platform_triple]}/pl-build-toolchain.cmake"

    # PCP-87: If we build with -O3, solaris segfaults due to something in std::vector
    special_flags = "-DCMAKE_CXX_FLAGS_RELEASE='-O2 -DNDEBUG'"
  elsif platform.is_windows?
    pkg.build_requires "cmake"
    pkg.build_requires "pl-toolchain-#{platform.architecture}"
    pkg.build_requires "pl-boost-#{platform.architecture}"

    make = "#{settings[:gcc_bindir]}/mingw32-make"
    pkg.environment "PATH" => "$$(cygpath -u #{settings[:gcc_bindir]}):/cygdrive/c/Windows/system32:/cygdrive/c/Windows:/cygdrive/c/Windows/System32/WindowsPowerShell/v1.0"
    pkg.environment "CYGWIN" => settings[:cygwin]

    cmake = "C:/ProgramData/chocolatey/bin/cmake.exe -G \"MinGW Makefiles\""
    toolchain = "-DCMAKE_TOOLCHAIN_FILE=#{settings[:tools_root]}/pl-build-toolchain.cmake"
  else
    pkg.build_requires "pl-gcc"
    pkg.build_requires "pl-cmake"
    pkg.build_requires "pl-boost"
  end

  pkg.configure do
    [
      "#{cmake}\
      #{toolchain} \
          -DCMAKE_VERBOSE_MAKEFILE=ON \
          -DCMAKE_PREFIX_PATH=#{settings[:prefix]} \
          -DCMAKE_INSTALL_PREFIX=#{settings[:prefix]} \
          -DCMAKE_SYSTEM_PREFIX_PATH=#{settings[:prefix]} \
          -DMODULES_INSTALL_PATH=#{File.join(settings[:install_root], 'pxp-agent', 'modules')} \
          #{special_flags} \
          -DBOOST_STATIC=ON \
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
  pkg.directory File.join(settings[:sysconfdir], 'pxp-agent', 'modules')
  pkg.directory File.join(settings[:install_root], 'pxp-agent', 'spool')
  pkg.directory File.join(settings[:logdir], 'pxp-agent')

  case platform.servicetype
  when "systemd"
    pkg.install_service "ext/systemd/pxp-agent.service", "ext/redhat/pxp-agent.sysconfig"
    pkg.install_configfile "ext/systemd/pxp-agent.logrotate", "/etc/logrotate.d/pxp-agent"
  when "sysv"
    if platform.is_deb?
      pkg.install_service "ext/debian/pxp-agent.init", "ext/debian/pxp-agent.default"
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
    puts "Service files not enabled on windows"
  else
    fail "need to know where to put #{pkg.get_name} service files"
  end
end
