component "facter" do |pkg, settings, platform|
  pkg.load_from_json('configs/components/facter.json')

  if platform.is_rpm?
    # In our rpm packages, facter has an epoch set, so we need to account for that here
    pkg.replaces 'facter', '1:3.0.0'
    pkg.provides 'facter', '1:3.0.0'
  else
    pkg.replaces 'facter', '3.0.0'
    pkg.provides 'facter', '3.0.0'
  end
  pkg.replaces 'cfacter', '0.5.0'
  pkg.provides 'cfacter', '0.5.0'

  pkg.replaces 'pe-facter'

  pkg.build_requires "ruby-#{settings[:ruby_version]}"
  if settings[:vendor_openssl] == "no"
    pkg.build_requires 'openssl-devel'
  else
    pkg.build_requires 'openssl'
  end

  pkg.build_requires 'leatherman'
  pkg.build_requires 'runtime' unless platform.use_native_tools?
  pkg.build_requires 'cpp-hocon'
  pkg.build_requires 'libwhereami'

  if platform.is_linux?
    # Running facter (as part of testing) expects virt-what is available
    pkg.build_requires 'virt-what'
  end

  # Running facter (as part of testing) expects augtool are available
  pkg.build_requires 'augeas' unless platform.is_windows?

  if platform.is_windows?
    pkg.environment "PATH", "$(shell cygpath -u #{settings[:gcc_bindir]}):$(shell cygpath -u #{settings[:ruby_bindir]}):$(shell cygpath -u #{settings[:bindir]}):/cygdrive/c/Windows/system32:/cygdrive/c/Windows:/cygdrive/c/Windows/System32/WindowsPowerShell/v1.0"
  else
    pkg.environment "PATH", "#{settings[:bindir]}:$(PATH)"
  end

  if platform.is_macos?
    pkg.build_requires "yaml-cpp"
  elsif platform.name =~ /solaris-10/
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-yaml-cpp-0.5.1.#{platform.architecture}.pkg.gz"
  elsif platform.is_cross_compiled_linux? || platform.name =~ /solaris-11/
    if platform.use_native_tools?
      pkg.build_requires "libyaml-cpp-dev:armhf"
    else
      pkg.build_requires "pl-yaml-cpp-#{platform.architecture}"
    end
  elsif platform.is_aix?
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-gcc-5.2.0-11.aix#{platform.os_version}.ppc.rpm"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-cmake-3.2.3-2.aix#{platform.os_version}.ppc.rpm"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-yaml-cpp-0.5.1-1.aix#{platform.os_version}.ppc.rpm"
  elsif platform.is_windows?
    pkg.build_requires "pl-yaml-cpp-#{platform.architecture}"
  elsif platform.use_native_tools?
    pkg.build_requires "cmake"
  else
    pkg.build_requires "pl-yaml-cpp"
  end

  # Explicitly skip jruby if not installing a jdk.
  skip_jruby = 'OFF'
  java_home = ''
  java_includedir = ''
  case platform.name
  when /el-(6|7)/
    pkg.build_requires 'java-1.8.0-openjdk-devel'
  when /(debian-(7|8)|ubuntu-14)/
    pkg.build_requires 'openjdk-7-jdk'
    java_home = "/usr/lib/jvm/java-7-openjdk-#{platform.architecture}"
  when /(debian-9|ubuntu-(15|16))/
    pkg.build_requires 'openjdk-8-jdk'
    java_home = "/usr/lib/jvm/java-8-openjdk-#{platform.architecture}"
  when /sles-12/
    pkg.build_requires 'java-1_7_0-openjdk-devel'
    java_home = "/usr/lib64/jvm/java-1.7.0-openjdk"
  when /sles-11/
    pkg.build_requires 'java-1_7_0-ibm-devel'
    java_home = "/usr/lib64/jvm/java-1.7.0-ibm-1.7.0"
    java_includedir = "-DJAVA_JVM_LIBRARY=/usr/lib64/jvm/java-1.7.0-ibm-1.7.0/include"
  else
    skip_jruby = 'ON'
  end

  if skip_jruby == 'OFF'
    settings[:java_available] = true
  else
    settings[:java_available] = false
  end

  if java_home
    pkg.environment "JAVA_HOME", java_home
  end

  # Skip blkid unless we can ensure it exists at build time. Otherwise we depend
  # on the vagaries of the system we build on.
  skip_blkid = 'ON'
  if platform.is_deb? || platform.is_cisco_wrlinux?
    pkg.build_requires "libblkid-dev"
    skip_blkid = 'OFF'
  elsif platform.is_rpm?
    if (platform.is_el? && platform.os_version.to_i >= 6) || (platform.is_sles? && platform.os_version.to_i >= 11) || platform.is_fedora?
      # Ensure libblkid-devel isn't installed for all cross-compiled builds,
      # otherwise the build will fail trying to link to the x86_64 libblkid:
      pkg.build_requires "libblkid-devel" unless platform.is_cross_compiled?
      skip_blkid = 'OFF'
    elsif (platform.is_el? && platform.os_version.to_i < 6) || (platform.is_sles? && platform.os_version.to_i < 11)
      pkg.build_requires "e2fsprogs-devel"
      skip_blkid = 'OFF'
    end
  end

  # curl is only used for compute clusters (GCE, EC2); so rpm, deb, and Windows
  skip_curl = 'ON'
  if (platform.is_linux? && !platform.is_cisco_wrlinux?) || platform.is_windows?
    pkg.build_requires "curl"
    skip_curl = 'OFF'
  end

  ruby = "#{settings[:host_ruby]} -rrbconfig"

  make = platform[:make]
  cp = platform[:cp]

  special_flags = " -DCMAKE_INSTALL_PREFIX=#{settings[:prefix]} "

  # cmake on OSX is provided by brew
  # a toolchain is not currently required for OSX since we're building with clang.
  if platform.is_macos?
    toolchain = ""
    cmake = "/usr/local/bin/cmake"
    special_flags += "-DCMAKE_CXX_FLAGS='#{settings[:cflags]}'"
  elsif platform.is_cross_compiled_linux?
    ruby = "#{settings[:host_ruby]} -r#{settings[:datadir]}/doc/rbconfig.rb"
    toolchain = "-DCMAKE_TOOLCHAIN_FILE=/opt/pl-build-tools/#{settings[:platform_triple]}/pl-build-toolchain.cmake"
    cmake = "/opt/pl-build-tools/bin/cmake"
    if platform.use_native_tools?
      cmake = "/usr/bin/cmake" 
      toolchain = "-DCMAKE_TOOLCHAIN_FILE=/toolchain"
    end
  elsif platform.is_solaris?
    if platform.architecture == 'sparc'
      ruby = "#{settings[:host_ruby]} -r#{settings[:datadir]}/doc/rbconfig.rb"
    end

    toolchain = "-DCMAKE_TOOLCHAIN_FILE=/opt/pl-build-tools/#{settings[:platform_triple]}/pl-build-toolchain.cmake"
    cmake = "/opt/pl-build-tools/i386-pc-solaris2.#{platform.os_version}/bin/cmake"

    # FACT-1156: If we build with -O3, solaris segfaults due to something in std::vector
    special_flags += " -DCMAKE_CXX_FLAGS_RELEASE='-O2 -DNDEBUG' "
  elsif platform.is_windows?
    make = "#{settings[:gcc_bindir]}/mingw32-make"
    pkg.environment "CYGWIN", settings[:cygwin]

    cmake = "C:/ProgramData/chocolatey/bin/cmake.exe -G \"MinGW Makefiles\""
    toolchain = "-DCMAKE_TOOLCHAIN_FILE=#{settings[:tools_root]}/pl-build-toolchain.cmake"
    special_flags = "-DCMAKE_INSTALL_PREFIX=#{settings[:facter_root]} \
                     -DRUBY_LIB_INSTALL=#{settings[:facter_root]}/lib "
  else
    toolchain = "-DCMAKE_TOOLCHAIN_FILE=/opt/pl-build-tools/pl-build-toolchain.cmake"
    cmake = "/opt/pl-build-tools/bin/cmake"

    if platform.is_cisco_wrlinux?
      special_flags += " -DLEATHERMAN_USE_LOCALES=OFF"
    end
  end

  # In PE, aio_agent_version is distinguished from aio_agent_build by not including the git sha.
  # Strip it off; this should have no impact on final releases, as git sha would not be included.
  aio_agent_version = settings[:package_version].match(/^\d+\.\d+\.\d+(\.\d+){0,2}/).to_s

  unless platform.is_windows?
    special_flags += " -DFACTER_PATH=#{settings[:bindir]} \
                       -DFACTER_RUBY=/opt/puppetlabs/puppet/lib/libruby.so \
                       -DRUBY_LIB_INSTALL=#{settings[:ruby_vendordir]}"
  end

 if platform.name =~ /debian-9-armhf/
     boost_libs= "-DBOOST_LIBRARYDIR=/usr/lib/arm-linux-gnueabihf/lib -DLEATHERMAN_USE_LOCALES=OFF"
     boost_static="OFF"
  else
     boost_libs = ""
     boost_static="ON"
  end

  # FACTER_RUBY Needs bindir
  pkg.configure do
    ["#{cmake} \
        #{toolchain} \
        #{boost_libs} \
        -DLEATHERMAN_GETTEXT=ON \
        -DCMAKE_VERBOSE_MAKEFILE=ON \
        -DCMAKE_PREFIX_PATH=#{settings[:prefix]} \
        -DCMAKE_INSTALL_RPATH=#{settings[:libdir]} \
        #{special_flags} \
        -DBOOST_STATIC=#{boost_static} \
        -DYAMLCPP_STATIC=OFF \
        -DWITHOUT_CURL=#{skip_curl} \
        -DWITHOUT_BLKID=#{skip_blkid} \
        -DWITHOUT_JRUBY=#{skip_jruby} \
        -DAIO_AGENT_VERSION=#{aio_agent_version} \
        -DINSTALL_BATCH_FILES=NO \
        #{java_includedir} \
        ."]
  end

  pkg.build do
    ["#{make} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    ["#{make} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install"]
  end

  if platform.is_macos?
    ldd = "otool -L"
  else
    ldd = "ldd"
  end

  tests = []
  unless platform.is_windows? || platform.is_cross_compiled_linux? || platform.architecture == 'sparc'
    # Check that we're not linking against system libstdc++ and libgcc_s
    tests = [
      "#{ldd} lib/libfacter.so",
      "[ $$(#{ldd} lib/libfacter.so | grep -c libstdc++) -eq 0 ] || #{ldd} lib/libfacter.so | grep libstdc++ | grep -v ' /lib'",
      "[ $$(#{ldd} lib/libfacter.so | grep -c libgcc_s) -eq 0 ] || #{ldd} lib/libfacter.so | grep libgcc_s | grep -v ' /lib'",
    ]
  end

  # Make test will explode horribly in a cross-compile situation
  # Tests will be skipped on AIX until they are expected to pass
  if !platform.is_cross_compiled? && !platform.is_aix?
    tests << "LD_LIBRARY_PATH=#{settings[:libdir]} LIBPATH=#{settings[:libdir]} #{make} test ARGS=-V"
  end

  pkg.check do
    tests
  end

  pkg.install_file ".gemspec", "#{settings[:gem_home]}/specifications/#{pkg.get_name}.gemspec"
  if platform.is_windows?
    pkg.add_source("file://resources/files/windows/facter.bat", sum: "185b8645feecac4acadc55c64abb3755")
    pkg.add_source("file://resources/files/windows/facter_interactive.bat", sum: "20a1c0bc5368ffb24980f42432f1b372")
    pkg.add_source("file://resources/files/windows/run_facter_interactive.bat", sum: "c5e0c0a80e5c400a680a06a4bac8abd4")
    pkg.install_file "../facter.bat", "#{settings[:link_bindir]}/facter.bat"
    pkg.install_file "../facter_interactive.bat", "#{settings[:link_bindir]}/facter_interactive.bat"
    pkg.install_file "../run_facter_interactive.bat", "#{settings[:link_bindir]}/run_facter_interactive.bat"
  end
  if platform.is_windows?
    pkg.directory File.join(settings[:sysconfdir], 'facter', 'facts.d')
  else
    pkg.directory File.join(settings[:install_root], 'facter', 'facts.d')
  end
end
