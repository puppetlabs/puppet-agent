component "leatherman" do |pkg, settings, platform|
  pkg.load_from_json('configs/components/leatherman.json')

  make = platform[:make]

  if platform.is_macos?
    pkg.build_requires "cmake"
    pkg.build_requires "boost"
    pkg.build_requires "gettext"
  elsif platform.use_native_tools?
    pkg.build_requires "toolchain"
    pkg.build_requires "libboost-dev:armhf"
    pkg.build_requires "libboost-regex-dev:armhf"
    pkg.build_requires "libboost-atomic-dev:armhf"
    pkg.build_requires "libboost-chrono-dev:armhf"
    pkg.build_requires "libboost-date-time-dev:armhf"
    pkg.build_requires "libboost-exception-dev:armhf"
    pkg.build_requires "libboost-filesystem-dev:armhf"
    pkg.build_requires "libboost-graph-dev:armhf"
    pkg.build_requires "libboost-graph-parallel-dev:armhf"
    pkg.build_requires "libboost-iostreams-dev:armhf"
    pkg.build_requires "libboost-locale-dev:armhf"
    pkg.build_requires "libboost-log-dev:armhf"
    pkg.build_requires "libboost-math-dev:armhf"
    pkg.build_requires "libboost-program-options-dev:armhf"
    pkg.build_requires "libboost-random-dev:armhf"
    pkg.build_requires "libboost-serialization-dev:armhf"
    pkg.build_requires "libboost-signals-dev:armhf"
    pkg.build_requires "libboost-test-dev:armhf"
    pkg.build_requires "libboost-system-dev:armhf"
    pkg.build_requires "libboost-thread-dev:armhf"
    pkg.build_requires "libboost-timer-dev:armhf"
    pkg.build_requires "libboost-wave-dev:armhf"
    pkg.build_requires "cmake"
    pkg.build_requires "gettext"
  elsif platform.name =~ /solaris-10/
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-boost-1.58.0-7.#{platform.architecture}.pkg.gz"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-cmake-3.2.3-2.i386.pkg.gz"
  elsif platform.is_cross_compiled_linux? || platform.name =~ /solaris-11/
    pkg.build_requires "pl-boost-#{platform.architecture}"
    pkg.build_requires "pl-cmake"
  elsif platform.is_aix?
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-gcc-5.2.0-11.aix#{platform.os_version}.ppc.rpm"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-cmake-3.2.3-2.aix#{platform.os_version}.ppc.rpm"
    if platform.name =~ /aix-7.1/
      pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-boost-1.58.0-7.aix#{platform.os_version}.ppc.rpm"
    else
      pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-boost-1.58.0-1.aix#{platform.os_version}.ppc.rpm"
    end
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-gettext-0.19.8-2.aix#{platform.os_version}.ppc.rpm"
  elsif platform.is_windows?
    pkg.build_requires "cmake"
    pkg.build_requires "pl-toolchain-#{platform.architecture}"
    pkg.build_requires "pl-boost-#{platform.architecture}"
    pkg.build_requires "pl-gettext-#{platform.architecture}"
  else
    pkg.build_requires "pl-cmake"
    pkg.build_requires "pl-boost"
    pkg.build_requires "pl-gettext"
  end

  pkg.build_requires "curl"
  pkg.build_requires "runtime" unless platform.use_native_tools?
  pkg.build_requires "ruby-#{settings[:ruby_version]}"

  ruby = "#{settings[:host_ruby]} -rrbconfig"

  leatherman_locale_var = ""

  # cmake on OSX is provided by brew
  # a toolchain is not currently required for OSX since we're building with clang.
  if platform.is_macos?
    toolchain = ""
    cmake = "/usr/local/bin/cmake"
    special_flags = "-DCMAKE_CXX_FLAGS='#{settings[:cflags]}' -DLEATHERMAN_MOCK_CURL=FALSE"
  elsif platform.is_cross_compiled_linux?
    ruby = "#{settings[:host_ruby]} -r#{settings[:datadir]}/doc/rbconfig.rb"
    if platform.use_native_tools?
      toolchain = "-DCMAKE_TOOLCHAIN_FILE=#{settings[:datadir]}/doc/debian-armhf-toolchain"
      cmake = "/usr/bin/cmake"
    else
      toolchain = "-DCMAKE_TOOLCHAIN_FILE=/opt/pl-build-tools/#{settings[:platform_triple]}/pl-build-toolchain.cmake"
      cmake = "/opt/pl-build-tools/bin/cmake"
    end
  elsif platform.is_solaris?
    if platform.architecture == 'sparc'
      ruby = "#{settings[:host_ruby]} -r#{settings[:datadir]}/doc/rbconfig.rb"
    end

    toolchain = "-DCMAKE_TOOLCHAIN_FILE=/opt/pl-build-tools/#{settings[:platform_triple]}/pl-build-toolchain.cmake"
    cmake = "/opt/pl-build-tools/i386-pc-solaris2.#{platform.os_version}/bin/cmake"

    # FACT-1156: If we build with -O3, solaris segfaults due to something in std::vector
    special_flags = "-DCMAKE_CXX_FLAGS_RELEASE='-O2 -DNDEBUG'"
  elsif platform.is_windows?
    make = "#{settings[:gcc_bindir]}/mingw32-make"
    pkg.environment "PATH", "$(shell cygpath -u #{settings[:gcc_bindir]}):$(shell cygpath -u #{settings[:ruby_bindir]}):/cygdrive/c/Windows/system32:/cygdrive/c/Windows:/cygdrive/c/Windows/System32/WindowsPowerShell/v1.0"
    pkg.environment "CYGWIN", settings[:cygwin]

    cmake = "C:/ProgramData/chocolatey/bin/cmake.exe -G \"MinGW Makefiles\""
    toolchain = "-DCMAKE_TOOLCHAIN_FILE=#{settings[:tools_root]}/pl-build-toolchain.cmake"

    # Use environment variable set in environment.bat to find locale files
    leatherman_locale_var = "-DLEATHERMAN_LOCALE_VAR='PUPPET_DIR' -DLEATHERMAN_LOCALE_INSTALL='share/locale'"
  else
    toolchain = "-DCMAKE_TOOLCHAIN_FILE=/opt/pl-build-tools/pl-build-toolchain.cmake"
    cmake = "/opt/pl-build-tools/bin/cmake"

    if platform.is_cisco_wrlinux?
      special_flags = "-DLEATHERMAN_USE_LOCALES=OFF"
    end
  end

  if platform.is_linux?
    # Ensure our gettext packages are found before system versions
    pkg.environment "PATH", "/opt/pl-build-tools/bin:$(PATH)"
  end


  if platform.name =~ /debian-9-armhf/
     boost_libs= "-DBOOST_LIBRARYDIR=/usr/lib/arm-linux-gnueabihf/lib"
     boost_static="OFF"
  else
     boost_libs = ""
     boost_static="ON"
  end

  pkg.configure do
    ["#{cmake} \
        #{toolchain} \
        #{boost_libs} \
        -DLEATHERMAN_GETTEXT=ON \
        -DCMAKE_VERBOSE_MAKEFILE=ON \
        -DCMAKE_PREFIX_PATH=#{settings[:prefix]} \
        -DCMAKE_INSTALL_PREFIX=#{settings[:prefix]} \
        -DCMAKE_INSTALL_RPATH=#{settings[:libdir]} \
        -DLEATHERMAN_USE_ICU=TRUE \
        #{leatherman_locale_var} \
        -DLEATHERMAN_SHARED=TRUE \
        #{special_flags} \
        -DBOOST_STATIC=#{boost_static} \
        ."]
  end

  pkg.build do
    ["#{make} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  # Make test will explode horribly in a cross-compile situation
  # Tests will be skipped on AIX until they are expected to pass
  if !platform.is_cross_compiled? && !platform.is_aix?
    if platform.is_solaris? && platform.architecture != 'sparc'
      test_locale = "LANG=C LC_ALL=C"
    end

    pkg.check do
      ["LEATHERMAN_RUBY=#{settings[:libdir]}/$(shell #{ruby} -e 'print RbConfig::CONFIG[\"LIBRUBY_SO\"]') \
       LD_LIBRARY_PATH=#{settings[:libdir]} LIBPATH=#{settings[:libdir]} #{test_locale} #{make} test ARGS=-V"]
    end
  end

  pkg.install do
    ["#{make} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install"]
  end
end
