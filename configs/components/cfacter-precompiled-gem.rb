component "cfacter-precompiled-gem" do |pkg, settings, platform|
  pkg.build_requires 'cfacter-source-gem'

  pkg.add_source("file://resources/files/cfacter-gem/cfacter-precompiled.gemspec.erb", erb: 'true')
  pkg.install_file('cfacter-precompiled.gemspec', "#{settings[:gemdir]}")

  if platform.is_osx?
    pkg.build_requires "cmake"
    pkg.build_requires "boost"
    pkg.build_requires "yaml-cpp"
  elsif platform.is_windows?
    pkg.build_requires "cmake"
    pkg.build_requires "pl-toolchain-#{platform.architecture}"
    pkg.build_requires "pl-boost-#{platform.architecture}"
    pkg.build_requires "pl-yaml-cpp-#{platform.architecture}"
  else
    pkg.build_requires "pl-gcc"
    pkg.build_requires "pl-cmake"
    pkg.build_requires "pl-boost"
    pkg.build_requires "pl-yaml-cpp"
  end

  pkg.add_source("file://resources/files/cfacter-gem/make.bat")
  pkg.install_file('make.bat', "#{settings[:build_tools_dir]}")

  if platform.is_osx?
    make = 'make'
    pkg.environment "PATH" => "/usr/local/bin:#{settings[:build_tools_dir]}:#{settings[:ruby_dir]}:$$PATH"
    pkg.environment('FACTER_CMAKE_OPTS', "-DBOOST_STATIC=ON -DYAMLCPP_STATIC=ON -DLEATHERMAN_USE_CURL=FALSE -DWITHOUT_CURL=TRUE -DWITHOUT_OPENSSL=TRUE -DWITHOUT_BLKID=TRUE -DFACTER_SKIP_TESTS=TRUE -DWITHOUT_JRUBY=ON")
  elsif platform.is_windows?
    make = "#{settings[:gcc_bindir]}/mingw32-make"
    pkg.environment "PATH" => "/cygdrive/c/ProgramData/chocolatey/bin:$$(cygpath -u #{settings[:gcc_bindir]}):$$(cygpath -u #{settings[:build_tools_dir]}):$$(cygpath -u #{settings[:ruby_dir]}):/cygdrive/c/Windows/system32:/cygdrive/c/Windows:/cygdrive/c/Windows/System32/WindowsPowerShell/v1.0"
    pkg.environment('FACTER_CMAKE_OPTS', '-G \"MinGW Makefiles\" -DBOOST_STATIC=ON -DYAMLCPP_STATIC=ON -DLEATHERMAN_USE_CURL=FALSE -DWITHOUT_CURL=TRUE -DWITHOUT_OPENSSL=TRUE -DWITHOUT_BLKID=TRUE -DFACTER_SKIP_TESTS=TRUE -DCMAKE_TOOLCHAIN_FILE=C:\tools\pl-build-tools\pl-build-toolchain.cmake -DWITHOUT_JRUBY=ON')
  else
    make = 'make'
    pkg.environment "PATH" => "#{settings[:build_tools_dir]}:#{settings[:ruby_dir]}:$$PATH"
    pkg.environment('FACTER_CMAKE_OPTS', "-DBOOST_STATIC=ON -DYAMLCPP_STATIC=ON -DLEATHERMAN_USE_CURL=FALSE -DWITHOUT_CURL=TRUE -DWITHOUT_OPENSSL=TRUE -DWITHOUT_BLKID=TRUE -DFACTER_SKIP_TESTS=TRUE -DWITHOUT_JRUBY=ON")
  end


  pkg.install do
    [
      "pushd #{settings[:gemdir]}",
      "rm cfacter*.gem",
      "pushd ext/facter",
      "#{settings[:ruby_binary]} extconf.rb",
      "#{make} install",
      "popd",
      "#{settings[:gem_binary]} build cfacter-precompiled.gemspec",
      "popd"
    ]
  end
end
