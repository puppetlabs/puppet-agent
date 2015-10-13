component "cpp-pcp-client" do |pkg, settings, platform|
  pkg.load_from_json('configs/components/cpp-pcp-client.json')
  cmake = "/opt/pl-build-tools/bin/cmake"
  toolchain = "-DCMAKE_TOOLCHAIN_FILE=/opt/pl-build-tools/pl-build-toolchain.cmake"
  pkg.environment "PATH" => "#{settings[:bindir]}:/opt/pl-build-tools/bin:$$PATH"

  pkg.build_requires "openssl"
  if platform.is_aix?
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-gcc-5.2.0-1.aix#{platform.os_version}.ppc.rpm"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-cmake-3.2.3-1.aix#{platform.os_version}.ppc.rpm"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-boost-1.58.0-1.aix#{platform.os_version}.ppc.rpm"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-yaml-cpp-0.5.1-1.aix#{platform.os_version}.ppc.rpm"
  elsif platform.is_osx?
    cmake = "/usr/local/bin/cmake"
    toolchain = ""
    cmake_extra_args = "-DCMAKE_MACOSX_RPATH=ON \
        -DCMAKE_INSTALL_RPATH=#{settings[:prefix]}/lib"
  elsif platform.is_solaris?
    cmake = "/opt/pl-build-tools/i386-pc-solaris2.#{platform.os_version}/bin/cmake"
    toolchain = "-DCMAKE_TOOLCHAIN_FILE=/opt/pl-build-tools/#{settings[:platform_triple]}/pl-build-toolchain.cmake"
  else
    pkg.build_requires "pl-gcc"
    pkg.build_requires "pl-cmake"
    pkg.build_requires "pl-boost"
  end

  pkg.configure do
    [
      "#{cmake} \
      #{toolchain} \
          -DCMAKE_VERBOSE_MAKEFILE=ON \
          -DCMAKE_PREFIX_PATH=#{settings[:prefix]} \
          -DCMAKE_INSTALL_PREFIX=#{settings[:prefix]} \
          -DCMAKE_SYSTEM_PREFIX_PATH=#{settings[:prefix]} \
          -DBOOST_STATIC=ON \
          #{cmake_extra_args} \
          ."
    ]
  end

  pkg.build do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install"]
  end
end
