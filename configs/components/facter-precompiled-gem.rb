component "facter-precompiled-gem" do |pkg, settings, platform|
  pkg.build_requires 'facter-source-gem'

  pkg.add_source("file://resources/files/facter-gem/facter-precompiled.gemspec.erb")

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

  pkg.add_source("file://resources/files/facter-gem/make.bat")
  pkg.install_file('make.bat', "#{settings[:build_tools_dir]}")

  if platform.is_osx?
    make = 'make'
    rm = 'rm'
    pkg.environment "PATH" => "/usr/local/bin:#{settings[:build_tools_dir]}:#{settings[:ruby_dir]}:$$PATH"
    pkg.environment('FACTER_CMAKE_OPTS', "-DBOOST_STATIC=ON -DYAMLCPP_STATIC=ON -DLEATHERMAN_USE_CURL=FALSE -DWITHOUT_CURL=TRUE -DWITHOUT_OPENSSL=TRUE -DWITHOUT_BLKID=TRUE -DFACTER_SKIP_TESTS=TRUE -DWITHOUT_JRUBY=ON")
    gem_directory = settings[:gemdir]
  elsif platform.is_windows?
    make = "#{settings[:gcc_bindir]}/mingw32-make"
    rm = '/bin/rm'
    pkg.environment "PATH" => "/cygdrive/c/ProgramData/chocolatey/bin:$$(cygpath -u #{settings[:gcc_bindir]}):$$(cygpath -u #{settings[:build_tools_dir]}):$$(cygpath -u #{settings[:ruby_dir]}):/cygdrive/c/Windows/system32:/cygdrive/c/Windows:/cygdrive/c/Windows/System32/WindowsPowerShell/v1.0"
    pkg.environment('FACTER_CMAKE_OPTS', '-G \"MinGW Makefiles\" -DBOOST_STATIC=ON -DYAMLCPP_STATIC=ON -DLEATHERMAN_USE_CURL=FALSE -DWITHOUT_CURL=TRUE -DWITHOUT_OPENSSL=TRUE -DWITHOUT_BLKID=TRUE -DFACTER_SKIP_TESTS=TRUE -DCMAKE_TOOLCHAIN_FILE=C:\tools\pl-build-tools\pl-build-toolchain.cmake -DWITHOUT_JRUBY=ON')
    # Once we are executing ruby code using the ruby binary,
    # cygwin is no longer available, so we'll need to fully
    # qualify the gem directory including the windows paths
    gem_directory = 'C:/cygwin64' + settings[:gemdir]
  else
    make = 'make'
    rm = 'rm'
    pkg.environment "PATH" => "#{settings[:build_tools_dir]}:#{settings[:ruby_dir]}:$$PATH"
    pkg.environment('FACTER_CMAKE_OPTS', "-DBOOST_STATIC=ON -DYAMLCPP_STATIC=ON -DLEATHERMAN_USE_CURL=FALSE -DWITHOUT_CURL=TRUE -DWITHOUT_OPENSSL=TRUE -DWITHOUT_BLKID=TRUE -DFACTER_SKIP_TESTS=TRUE -DWITHOUT_JRUBY=ON")
    gem_directory = settings[:gemdir]
  end

  pkg.configure do
    [
      "#{settings[:ruby_binary]} generate-gemspec.rb facter-precompiled.gemspec.erb '#{gem_directory}' '#{settings[:project_version]}'"
    ]
  end

  pkg.install do
    [
      "pushd #{settings[:gemdir]}",
      "#{rm} facter*.gem",
      "pushd ext/facter",
      "#{settings[:ruby_binary]} extconf.rb",
      "#{make} install",
      "popd",
      "#{settings[:gem_binary]} build facter-precompiled.gemspec",
      "popd"
    ]
  end
end
