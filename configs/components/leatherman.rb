component "leatherman" do |pkg, settings, platform|
  pkg.load_from_json('configs/components/leatherman.json')

  make = platform[:make]

  if platform.is_osx?
    pkg.build_requires "cmake"
    pkg.build_requires "boost"
  elsif platform.name =~ /solaris-10/
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-gcc-4.8.2-1.#{platform.architecture}.pkg.gz"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-binutils-2.25.#{platform.architecture}.pkg.gz"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-boost-1.58.0-1.#{platform.architecture}.pkg.gz"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-cmake-3.2.3-2.i386.pkg.gz"
  elsif platform.is_cross_compiled_linux? || platform.name =~ /solaris-11/
    pkg.build_requires "pl-gcc-#{platform.architecture}"
    pkg.build_requires "pl-boost-#{platform.architecture}"
    pkg.build_requires "pl-cmake"
  elsif platform.is_aix?
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-gcc-5.2.0-11.aix#{platform.os_version}.ppc.rpm"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-cmake-3.2.3-2.aix#{platform.os_version}.ppc.rpm"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-boost-1.58.0-1.aix#{platform.os_version}.ppc.rpm"
  elsif platform.is_windows?
    pkg.build_requires "cmake"
    pkg.build_requires "pl-toolchain-#{platform.architecture}"
    pkg.build_requires "pl-boost-#{platform.architecture}"
  else
    pkg.build_requires "pl-gcc"
    pkg.build_requires "pl-cmake"
    pkg.build_requires "pl-boost"
  end

  # curl is only used for compute clusters (GCE, EC2); so rpm, deb, and Windows
  use_curl = 'FALSE'
  if (platform.is_linux? && !platform.is_cisco_wrlinux?) || platform.is_windows?
    pkg.build_requires "curl"
    use_curl = 'TRUE'
  end

  pkg.build_requires "runtime"
  pkg.build_requires "ruby-#{settings[:ruby_version]}"

  ruby = "#{settings[:host_ruby]} -rrbconfig"

  # cmake on OSX is provided by brew
  # a toolchain is not currently required for OSX since we're building with clang.
  if platform.is_osx?
    toolchain = ""
    cmake = "/usr/local/bin/cmake"
    special_flags = "-DCMAKE_CXX_FLAGS='#{settings[:cflags]}'"
  elsif platform.is_cross_compiled_linux?
    ruby = "#{settings[:host_ruby]} -r#{settings[:datadir]}/doc/rbconfig.rb"
    toolchain = "-DCMAKE_TOOLCHAIN_FILE=/opt/pl-build-tools/#{settings[:platform_triple]}/pl-build-toolchain.cmake"
    cmake = "/opt/pl-build-tools/bin/cmake"
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
    pkg.environment "PATH" => "$$(cygpath -u #{settings[:gcc_bindir]}):$$(cygpath -u #{settings[:ruby_bindir]}):/cygdrive/c/Windows/system32:/cygdrive/c/Windows:/cygdrive/c/Windows/System32/WindowsPowerShell/v1.0"
    pkg.environment "CYGWIN" => settings[:cygwin]

    cmake = "C:/ProgramData/chocolatey/bin/cmake.exe -G \"MinGW Makefiles\""
    toolchain = "-DCMAKE_TOOLCHAIN_FILE=#{settings[:tools_root]}/pl-build-toolchain.cmake"
  else
    toolchain = "-DCMAKE_TOOLCHAIN_FILE=/opt/pl-build-tools/pl-build-toolchain.cmake"
    cmake = "/opt/pl-build-tools/bin/cmake"

    if platform.is_cisco_wrlinux?
      special_flags = "-DLEATHERMAN_USE_LOCALES=OFF"
    end
  end

  # Until we build our own gettext packages, disable using locales.
  # gettext 0.17 is required to compile .mo files with msgctxt.
  pkg.configure do
    ["#{cmake} \
        #{toolchain} \
        -DLEATHERMAN_GETTEXT=OFF \
        -DCMAKE_VERBOSE_MAKEFILE=ON \
        -DCMAKE_PREFIX_PATH=#{settings[:prefix]} \
        -DCMAKE_INSTALL_PREFIX=#{settings[:prefix]} \
        -DCMAKE_INSTALL_RPATH=#{settings[:libdir]} \
        -DLEATHERMAN_SHARED=TRUE \
        #{special_flags} \
        -DBOOST_STATIC=ON \
        -DLEATHERMAN_USE_CURL=#{use_curl} \
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
