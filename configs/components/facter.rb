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

  if platform.is_linux?
    # Running facter (as part of testing) expects virt-what is available
    pkg.build_requires 'virt-what'
  end

  pkg.environment "PATH" => "#{settings[:bindir]}:$$PATH"

  # OSX uses clang and system openssl.  cmake comes from brew.
  if platform.is_osx?
    pkg.build_requires "cmake"
    pkg.build_requires "boost"
    pkg.build_requires "yaml-cpp --with-static-lib"
  elsif platform.is_solaris?
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-gcc-4.8.2.#{platform.architecture}.pkg.gz"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-binutils-2.25.#{platform.architecture}.pkg.gz"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-boost-1.57.0.#{platform.architecture}.pkg.gz"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-yaml-cpp-0.5.1.#{platform.architecture}.pkg.gz"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-cmake-3.2.3.i386.pkg.gz"
  else
    pkg.build_requires "openssl"
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
  when /el-(6|7)/
    pkg.build_requires 'java-1.8.0-openjdk-devel'
  when /debian-(7|8)-amd64/
    pkg.build_requires 'openjdk-7-jdk'
    java_home = "/usr/lib/jvm/java-7-openjdk-amd64"
  when /debian-(7|8)-i386/
    pkg.build_requires 'openjdk-7-jdk'
    java_home = "/usr/lib/jvm/java-7-openjdk-i386"
  when /ubuntu-(12\.04|14\.\d{2})-amd64/
    pkg.build_requires 'openjdk-7-jdk'
    java_home = "/usr/lib/jvm/java-7-openjdk-amd64"
  when /ubuntu-(12\.04|14\.\d{2})-i386/
    pkg.build_requires 'openjdk-7-jdk'
    java_home = "/usr/lib/jvm/java-7-openjdk-i386"
  when /fedora-f20/
    pkg.build_requires 'java-1.7.0-openjdk-devel'
  when /fedora-f21/
    pkg.build_requires 'java-1.8.0-openjdk-devel'
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

  if java_home
    pkg.environment "JAVA_HOME" => java_home
  end

  # Skip blkid unless we can ensure it exists at build time. Otherwise we depend
  # on the vagaries of the system we build on.
  skip_blkid = 'ON'
  if platform.is_deb? or platform.is_nxos?
    pkg.build_requires "libblkid-dev"
    skip_blkid = 'OFF'
  elsif platform.is_rpm?
    if (platform.is_el? and platform.os_version.to_i >= 6) or (platform.is_sles? and platform.os_version.to_i >= 11)
      pkg.build_requires "libblkid-devel"
      skip_blkid = 'OFF'
    end
  end

  # curl is only used for compute clusters (GCE, EC2); so rpm, deb, and Windows
  skip_curl = 'ON'
  if platform.is_rpm? || platform.is_deb?
    pkg.build_requires "curl"
    skip_curl = 'OFF'
  end

  ruby = "#{File.join(settings[:bindir], 'ruby')} -rrbconfig"

  # cmake on OSX is provided by brew
  # a toolchain is not currently required for OSX since we're building with clang.
  if platform.is_osx?
    toolchain = ""
    cmake = "/usr/local/bin/cmake"
  elsif platform.is_solaris?
    ruby = "/opt/csw/bin/ruby -r#{settings[:datadir]}/doc/rbconfig.rb"
    toolchain = "-DCMAKE_TOOLCHAIN_FILE=/opt/pl-build-tools/#{settings[:platform_triple]}/pl-build-toolchain.cmake"
    cmake = "/opt/pl-build-tools/i386-pc-solaris2.10/bin/cmake"

    # FACT-1156: If we build with -O3, solaris segfaults due to something in std::vector
    special_flags = "-DCMAKE_CXX_FLAGS_RELEASE='-O2 -DNDEBUG'"
  else
    toolchain = "-DCMAKE_TOOLCHAIN_FILE=/opt/pl-build-tools/pl-build-toolchain.cmake"
    cmake = "/opt/pl-build-tools/bin/cmake"
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
  if platform.architecture == "sparc"
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

  pkg.link "#{settings[:bindir]}/facter", "#{settings[:link_bindir]}/facter"
  pkg.directory File.join('/opt/puppetlabs', 'facter', 'facts.d')
end
