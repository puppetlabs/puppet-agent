component "cfacter" do |pkg, settings, platform|
  pkg.url "git://github.com/puppetlabs/cfacter"
  pkg.ref "origin/master"

  pkg.build_requires "pl-gcc"
  pkg.build_requires "pl-cmake"
  pkg.build_requires "pl-libboost-static"
  pkg.build_requires "pl-libboost-devel"
  pkg.build_requires "pl-libyaml-cpp-static"
  pkg.build_requires "pl-libyaml-cpp-devel"

  pkg.configure do
    ["/opt/pl-build-tools/bin/cmake \
          -DCMAKE_TOOLCHAIN_FILE=/opt/pl-build-tools/pl-build-toolchain.cmake \
          -DCMAKE_VERBOSE_MAKEFILE=ON \
          -DCMAKE_INSTALL_PREFIX=#{settings[:prefix]} \
          -DBOOST_STATIC=ON \
          -DYAMLCPP_STATIC=ON \
          ."]
  end

  pkg.build do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install"]
  end
end
