component "leatherman" do |pkg, settings, platform|
  pkg.load_from_json('configs/components/leatherman.json')

  make = platform[:make]

  if platform.is_macos?
    pkg.build_requires "cmake"
    pkg.build_requires "gettext"
  elsif platform.name =~ /solaris-10/
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-cmake-3.2.3-2.i386.pkg.gz"
  elsif platform.is_cross_compiled_linux? || platform.name =~ /solaris-11/
    pkg.build_requires "pl-cmake"
  elsif platform.is_aix?
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-gcc-5.2.0-11.aix#{platform.os_version}.ppc.rpm"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-cmake-3.2.3-2.aix#{platform.os_version}.ppc.rpm"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-gettext-0.19.8-2.aix#{platform.os_version}.ppc.rpm"
  elsif platform.is_windows?
    pkg.build_requires "cmake"
    pkg.build_requires "pl-toolchain-#{platform.architecture}"
    pkg.build_requires "pl-gettext-#{platform.architecture}"
  elsif platform.name =~ /sles-15|fedora-(29|30)|el-8|debian-10/
    # These platforms use their default OS toolchain and have package
    # dependencies configured in the platform provisioning step.
  else
    pkg.build_requires "pl-cmake"
    pkg.build_requires "pl-gettext"
  end

  pkg.build_requires "puppet-runtime" # Provides curl and ruby
  pkg.build_requires "runtime" unless platform.name =~ /sles-15|fedora-(29|30)|el-8|debian-10/

  ruby = "#{settings[:host_ruby]} -rrbconfig"

  leatherman_locale_var = ""
  special_flags = ""
  boost_static_flag = ""

  # cmake on OSX is provided by brew
  # a toolchain is not currently required for OSX since we're building with clang.
  if platform.is_macos?
    toolchain = ""
    cmake = "/usr/local/bin/cmake"
    boost_static_flag = "-DBOOST_STATIC=OFF"
    if platform.name =~ /osx-10.14/
      special_flags = "-DCMAKE_CXX_FLAGS='#{settings[:cflags]} -Wno-expansion-to-defined' -DLEATHERMAN_MOCK_CURL=FALSE"
    else
      special_flags = "-DCMAKE_CXX_FLAGS='#{settings[:cflags]}' -DLEATHERMAN_MOCK_CURL=FALSE"
    end
  elsif platform.is_cross_compiled_linux?
    ruby = "#{settings[:host_ruby]} -r#{settings[:datadir]}/doc/rbconfig-#{settings[:ruby_version]}-orig.rb"
    toolchain = "-DCMAKE_TOOLCHAIN_FILE=/opt/pl-build-tools/#{settings[:platform_triple]}/pl-build-toolchain.cmake"
    cmake = "/opt/pl-build-tools/bin/cmake"
  elsif platform.is_solaris?
    if platform.architecture == 'sparc'
      ruby = "#{settings[:host_ruby]} -r#{settings[:datadir]}/doc/rbconfig-#{settings[:ruby_version]}-orig.rb"
      special_flags += " -DCMAKE_EXE_LINKER_FLAGS=' /opt/puppetlabs/puppet/lib/libssl.so /opt/puppetlabs/puppet/lib/libcrypto.so' "
    end

    toolchain = "-DCMAKE_TOOLCHAIN_FILE=/opt/pl-build-tools/#{settings[:platform_triple]}/pl-build-toolchain.cmake"
    cmake = "/opt/pl-build-tools/i386-pc-solaris2.#{platform.os_version}/bin/cmake"

    # FACT-1156: If we build with -O3, solaris segfaults due to something in std::vector
    special_flags += "-DCMAKE_CXX_FLAGS_RELEASE='-O2 -DNDEBUG'"
  elsif platform.is_windows?
    make = "#{settings[:gcc_bindir]}/mingw32-make"
    pkg.environment "PATH", "$(shell cygpath -u #{settings[:libdir]}):$(shell cygpath -u #{settings[:gcc_bindir]}):$(shell cygpath -u #{settings[:bindir]}):/cygdrive/c/Windows/system32:/cygdrive/c/Windows:/cygdrive/c/Windows/System32/WindowsPowerShell/v1.0"
    pkg.environment "CYGWIN", settings[:cygwin]

    cmake = "C:/ProgramData/chocolatey/bin/cmake.exe -G \"MinGW Makefiles\""
    toolchain = "-DCMAKE_TOOLCHAIN_FILE=#{settings[:tools_root]}/pl-build-toolchain.cmake"

    # Use environment variable set in environment.bat to find locale files
    leatherman_locale_var = "-DLEATHERMAN_LOCALE_VAR='PUPPET_DIR' -DLEATHERMAN_LOCALE_INSTALL='share/locale'"
  elsif platform.name =~ /sles-15|fedora-(29|30)|el-8|debian-10/
    # These platforms use the default OS toolchain, rather than pl-build-tools
    cmake = "cmake"
    toolchain = ""
    boost_static_flag = ""
    special_flags = " -DENABLE_CXX_WERROR=OFF -DCMAKE_CXX_FLAGS='-O1' " if platform.name =~ /el-8|fedora-(29|30)|debian-10/
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

  pkg.configure do
    ["#{cmake} \
        #{toolchain} \
        -DLEATHERMAN_GETTEXT=ON \
        -DCMAKE_VERBOSE_MAKEFILE=ON \
        -DCMAKE_PREFIX_PATH=#{settings[:prefix]} \
        -DCMAKE_INSTALL_PREFIX=#{settings[:prefix]} \
        -DCMAKE_INSTALL_RPATH=#{settings[:libdir]} \
        #{leatherman_locale_var} \
        -DLEATHERMAN_SHARED=TRUE \
        #{special_flags} \
        #{boost_static_flag} \
        ."]
  end

  pkg.build do
    ["#{make} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  # Make test will explode horribly in a cross-compile situation
  # Tests will be skipped on AIX until they are expected to pass
  if !platform.is_cross_compiled? && !platform.is_aix?
    if platform.is_solaris? && platform.architecture != 'sparc' || platform.name =~ /debian-10/
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
