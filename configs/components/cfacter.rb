component "cfacter" do |pkg, settings, platform|
  pkg.load_from_json('configs/components/cfacter.json')

  pkg.build_requires "ruby"
  pkg.build_requires "openssl"
  pkg.build_requires "pl-gcc"
  pkg.build_requires "pl-cmake"
  pkg.build_requires "pl-boost"
  pkg.build_requires "pl-yaml-cpp"

  pkg.replaces 'cfacter', '0.5.0'
  pkg.provides 'cfacter', '0.5.0'


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
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install ARGS='-V'"]
  end

  pkg.link "#{settings[:bindir]}/cfacter", "#{settings[:link_bindir]}/cfacter"
end
