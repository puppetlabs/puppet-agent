component "facter" do |pkg, settings, platform|
  use_facter_2x = platform.is_eos?
  if use_facter_2x
    # Build facter-2.x
    pkg.load_from_json('configs/components/facter-2.x.json')
  else
    pkg.load_from_json('configs/components/facter.json')
  end

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

  # Running facter (as part of testing) expects virt-what is available
  pkg.build_requires 'virt-what'

  if use_facter_2x
    # facter requires the hostname command, which is provided by net-tools
    # on el5/6, but by hostname on more recent el releases including fedora
    # as well as all debian/ubuntu releases. The hostname package is not
    # available on sles
    if platform.is_deb? || (platform.is_el? && platform.os_version.to_i >= 7) || platform.is_fedora?
      pkg.requires 'hostname'
    end

    # net-tools is required for ifconfig
    pkg.requires 'net-tools'

    pkg.install do
      ["#{settings[:bindir]}/ruby install.rb --sitelibdir=#{settings[:ruby_vendordir]} --quick --man --mandir=#{settings[:mandir]}"]
    end
  else

    # OSX uses clang and system openssl.  cmake comes from brew.
    if platform.is_osx?
      pkg.build_requires "cmake"
      pkg.build_requires "boost"
      pkg.build_requires "yaml-cpp --with-static-lib"
    else
      pkg.build_requires "openssl"
      pkg.build_requires "pl-gcc"
      pkg.build_requires "pl-cmake"
      pkg.build_requires "pl-boost"
      pkg.build_requires "pl-yaml-cpp"
    end

    java_home = ''
    case platform.name
    when /el-(6|7)/
      pkg.build_requires 'java-1.8.0-openjdk-devel'
    when /debian-(7|8)/
      pkg.build_requires 'openjdk-7-jdk'
      java_home = "JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64"
    when /ubuntu-(12\.04|14\.\d{2})/
      pkg.build_requires 'openjdk-7-jdk'
      java_home = "JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64"
    when /fedora-f20/
      pkg.build_requires 'java-1.7.0-openjdk-devel'
    when /fedora-f21/
      pkg.build_requires 'java-1.8.0-openjdk-devel'
    when /osx-(10.9|10.10)/
      pkg.build_requires 'Caskroom/cask/java'
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

    # cmake on OSX is provided by brew
    # a toolchain is not currently required for OSX since we're building with clang.
    if platform.is_osx?
      toolchain=""
      cmake="/usr/local/bin/cmake"
    else
      toolchain="-DCMAKE_TOOLCHAIN_FILE=/opt/pl-build-tools/pl-build-toolchain.cmake"
      cmake="/opt/pl-build-tools/bin/cmake"
    end

    pkg.configure do
      ["PATH=#{settings[:bindir]}:$$PATH \
          #{java_home} \
          #{cmake} \
          #{toolchain} \
          -DCMAKE_VERBOSE_MAKEFILE=ON \
          -DCMAKE_PREFIX_PATH=#{settings[:prefix]} \
          -DCMAKE_INSTALL_PREFIX=#{settings[:prefix]} \
          -DBOOST_STATIC=ON \
          -DYAMLCPP_STATIC=ON \
          -DFACTER_PATH=#{settings[:bindir]} \
          -DFACTER_RUBY=#{settings[:libdir]}/$(shell #{settings[:bindir]}/ruby -rrbconfig -e 'print RbConfig::CONFIG[\"LIBRUBY_SO\"]') \
          -DWITHOUT_CURL=ON \
          -DWITHOUT_BLKID=#{skip_blkid} \
          ."]
    end

    pkg.build do
      # Until a `check` target exists, run tests are part of the build.
      ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) && #{platform[:make]} test ARGS=-V"]
    end

    pkg.install do
      ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install"]
    end
  end

  pkg.link "#{settings[:bindir]}/facter", "#{settings[:link_bindir]}/facter"
end
