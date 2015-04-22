component "facter" do |pkg, settings, platform|
  pkg.load_from_json('configs/components/facter.json')

  pkg.build_requires "ruby"
  pkg.build_requires "openssl"
  pkg.build_requires "pl-gcc"
  pkg.build_requires "pl-cmake"

  # Here we replace and provide facter 3 to ensure that even as we continue
  # to release 2.x versions of facter upgrades to puppet-agent will be clean
  if platform.is_rpm?
    # In our rpm packages, facter has an epoch set, so we need to account for that here
    pkg.replaces 'facter', '1:3.0.0'
    pkg.provides 'facter', '1:3.0.0'
    pkg.replaces 'cfacter', '0.5.0'
    pkg.provides 'cfacter', '0.5.0'
  else
    pkg.replaces 'facter', '3.0.0'
    pkg.provides 'facter', '3.0.0'
    pkg.replaces 'cfacter', '0.5.0'
    pkg.provides 'cfacter', '0.5.0'
  end


  # SLES and Debian 8 uses vanagon built pl-build-tools
  if platform.is_sles? or (platform.os_name == 'debian' and platform.os_version.to_i >= 8) or
      platform.name.match(/^ubuntu-14.10-.*$/)
    pkg.build_requires "pl-boost"
    pkg.build_requires "pl-yaml-cpp"
  else
    # these are from the pl-dependency repo
    pkg.build_requires "pl-libboost-static"
    pkg.build_requires "pl-libboost-devel"
    pkg.build_requires "pl-libyaml-cpp-static"
    pkg.build_requires "pl-libyaml-cpp-devel"
  end

  # Skip blkid unless we can ensure it exists at build time. Otherwise we depend
  # on the vagaries of the system we build on.
  skip_blkid = 'ON'
  if platform.is_deb?
    pkg.build_requires "libblkid-dev"
    skip_blkid = 'OFF'
  elsif platform.is_rpm?
    if (platform.is_el? and platform.os_version.to_i >= 6) or (platform.is_sles? and platform.os_version.to_i >= 11)
      pkg.build_requires "libblkid-devel"
      skip_blkid = 'OFF'
    end
  end

  pkg.configure do
    ["PATH=#{settings[:bindir]}:$$PATH \
          /opt/pl-build-tools/bin/cmake \
          -DCMAKE_TOOLCHAIN_FILE=/opt/pl-build-tools/pl-build-toolchain.cmake \
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
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) all test"]
  end

  pkg.install do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install"]
  end

  pkg.link "#{settings[:bindir]}/facter", "#{settings[:link_bindir]}/facter"
end
