component "cfacter" do |pkg, settings, platform|
  pkg.load_from_json('configs/components/cfacter.json')

  pkg.build_requires "ruby"
  pkg.build_requires "openssl"
  pkg.build_requires "pl-gcc"
  pkg.build_requires "pl-cmake"

  # SLES and Debian 8 uses vanagon built pl-build-tools
  if platform.is_sles? or (platform.is_deb? and platform.os_version >= 8)
    pkg.build_requires "pl-boost"
    pkg.build_requires "pl-yaml-cpp"
  else
    # these are from the pl-dependency repo
    pkg.build_requires "pl-libboost-static"
    pkg.build_requires "pl-libboost-devel"
    pkg.build_requires "pl-libyaml-cpp-static"
    pkg.build_requires "pl-libyaml-cpp-devel"
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
          ."]
  end

  pkg.build do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install"]
  end
end
