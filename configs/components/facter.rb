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

  pkg.build_requires "ruby"
  pkg.build_requires 'openssl'
  pkg.build_requires 'leatherman'

  if platform.is_linux? && !platform.is_huaweios?
    # Running facter (as part of testing) expects virt-what is available
    pkg.build_requires 'virt-what'
  end

  # Running facter (as part of testing) expects augtool are available
  pkg.build_requires 'augeas'
  pkg.build_requires "openssl"

  pkg.environment "PATH" => "#{settings[:bindir]}:$$PATH"

  # OSX uses clang and system openssl.  cmake comes from brew.
  if platform.is_osx?
    pkg.build_requires "cmake"
    pkg.build_requires "boost"
    pkg.build_requires "yaml-cpp"
  elsif platform.name =~ /solaris-10/
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-gcc-4.8.2-1.#{platform.architecture}.pkg.gz"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-binutils-2.25.#{platform.architecture}.pkg.gz"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-boost-1.58.0-1.#{platform.architecture}.pkg.gz"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-yaml-cpp-0.5.1.#{platform.architecture}.pkg.gz"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-cmake-3.2.3-2.i386.pkg.gz"
  elsif platform.name =~ /huaweios|solaris-11/
    pkg.build_requires "pl-gcc-#{platform.architecture}"
    pkg.build_requires "pl-cmake"
    pkg.build_requires "pl-boost-#{platform.architecture}"
    pkg.build_requires "pl-yaml-cpp-#{platform.architecture}"
  elsif platform.is_aix?
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-gcc-5.2.0-1.aix#{platform.os_version}.ppc.rpm"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-cmake-3.2.3-2.aix#{platform.os_version}.ppc.rpm"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-boost-1.58.0-1.aix#{platform.os_version}.ppc.rpm"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-yaml-cpp-0.5.1-1.aix#{platform.os_version}.ppc.rpm"
    pkg.build_requires "runtime"
  else
    pkg.build_requires "pl-gcc"
    pkg.build_requires "pl-cmake"
    pkg.build_requires "pl-boost"
    pkg.build_requires "pl-yaml-cpp"
  end

  # Explicitly skip jruby if not installing a jdk.
  skip_jruby = 'OFF'
  java_home = ''
  java_includedir = ''
  case platform.name
  when /fedora-f20/
    pkg.build_requires 'java-1.7.0-openjdk-devel'
  when /(el-(6|7)|fedora-(f21|f22|f23))/
    pkg.build_requires 'java-1.8.0-openjdk-devel'
  when /(debian-(7|8)|ubuntu-(12|14))/
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
    pkg.environment "JAVA_HOME" => java_home
  end

  # Skip blkid unless we can ensure it exists at build time. Otherwise we depend
  # on the vagaries of the system we build on.
  skip_blkid = 'ON'
  if platform.is_deb? || platform.is_cisco_wrlinux?
    pkg.build_requires "libblkid-dev"
    skip_blkid = 'OFF'
  elsif platform.is_rpm?
    if (platform.is_el? && platform.os_version.to_i >= 6) || (platform.is_sles? && platform.os_version.to_i >= 11) || platform.is_fedora?
      pkg.build_requires "libblkid-devel"
      skip_blkid = 'OFF'
    elsif (platform.is_el? && platform.os_version.to_i < 6) || (platform.is_sles? && platform.os_version.to_i < 11)
      pkg.build_requires "e2fsprogs-devel"
      skip_blkid = 'OFF'
    end
  end
  if platform.is_huaweios?
    skip_blkid = 'ON'
  end

  # curl is only used for compute clusters (GCE, EC2); so rpm, deb, and Windows
  skip_curl = 'ON'
  if platform.is_linux? && !platform.is_huaweios?
    pkg.build_requires "curl"
    skip_curl = 'OFF'
  end

  ruby = "#{settings[:host_ruby]} -rrbconfig"

  # cmake on OSX is provided by brew
  # a toolchain is not currently required for OSX since we're building with clang.
  if platform.is_osx?
    toolchain = ""
    cmake = "/usr/local/bin/cmake"
    special_flags = "-DCMAKE_CXX_FLAGS='#{settings[:cflags]}'"
  elsif platform.is_huaweios?
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
  else
    toolchain = "-DCMAKE_TOOLCHAIN_FILE=/opt/pl-build-tools/pl-build-toolchain.cmake"
    cmake = "/opt/pl-build-tools/bin/cmake"

    if platform.is_cisco_wrlinux?
      special_flags = "-DLEATHERMAN_USE_LOCALES=OFF"
    end
  end

  pkg.configure do
    ["#{cmake} \
        #{toolchain} \
        -DCMAKE_VERBOSE_MAKEFILE=ON \
        -DCMAKE_PREFIX_PATH=#{settings[:prefix]} \
        -DCMAKE_INSTALL_PREFIX=#{settings[:prefix]} \
        #{special_flags} \
        -DBOOST_STATIC=ON \
        -DYAMLCPP_STATIC=ON \
        -DFACTER_PATH=#{settings[:bindir]} \
        -DRUBY_LIB_INSTALL=#{settings[:ruby_vendordir]} \
        -DFACTER_RUBY=#{settings[:libdir]}/$(shell #{ruby} -e 'print RbConfig::CONFIG[\"LIBRUBY_SO\"]') \
        -DWITHOUT_CURL=#{skip_curl} \
        -DWITHOUT_BLKID=#{skip_blkid} \
        -DWITHOUT_JRUBY=#{skip_jruby} \
        #{java_includedir} \
        ."]
  end

  # Make test will explode horribly in a cross-compile situation
  # Tests will be skipped on AIX until they are expected to pass
  if platform.architecture == 'sparc' || platform.is_aix? || platform.is_huaweios?
    test = ":"
  else
    test = "#{platform[:make]} test ARGS=-V"
  end

  pkg.build do
    # Until a `check` target exists, run tests are part of the build.
    [
      "#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)",
      test
    ]
  end

  pkg.install do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install"]
  end

  pkg.install_file ".gemspec", "#{settings[:gem_home]}/specifications/#{pkg.get_name}.gemspec"

  pkg.link "#{settings[:bindir]}/facter", "#{settings[:link_bindir]}/facter"
  pkg.directory File.join('/opt/puppetlabs', 'facter')
  pkg.directory File.join('/opt/puppetlabs', 'facter', 'facts.d')
end
