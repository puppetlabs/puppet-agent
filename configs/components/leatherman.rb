component 'leatherman' do |pkg, settings, platform|
  pkg.load_from_json('configs/components/leatherman.json')

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
        #{cmake} \
        #{toolchain} \
        -DCMAKE_VERBOSE_MAKEFILE=ON \
        -DCMAKE_PREFIX_PATH=#{settings[:prefix]} \
        -DCMAKE_INSTALL_PREFIX=#{settings[:prefix]} \
        -DBOOST_STATIC=ON \
        ."]
  end

  pkg.build do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install"]
  end
end
