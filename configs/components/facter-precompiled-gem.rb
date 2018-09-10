component "facter-precompiled-gem" do |pkg, settings, platform|
  pkg.build_requires 'puppet-runtime' # provides boost and yaml-cpp
  pkg.build_requires 'facter-source-gem'

  pkg.add_source("file://resources/files/facter-gem/facter-precompiled.gemspec.erb")

  if platform.is_osx?
    pkg.build_requires "cmake"
  elsif platform.is_windows?
    pkg.build_requires "cmake"
    pkg.build_requires "pl-toolchain-#{platform.architecture}"
  elsif platform.name =~ /sles-15/
    # These platforms use their default OS toolchain and have package
    # dependencies configured in the platform provisioning step.
  else
    pkg.build_requires "pl-gcc"
    pkg.build_requires "pl-cmake"
  end

  pkg.add_source("file://resources/files/facter-gem/make.bat")
  pkg.install_file('make.bat', "#{settings[:build_tools_dir]}")

  if platform.is_osx?
    make = 'make'
    rm = 'rm'
    pkg.environment "PATH" => "/usr/local/bin:#{settings[:build_tools_dir]}:#{settings[:ruby_dir]}:$$PATH"
    pkg.environment('FACTER_CMAKE_OPTS', "-DLEATHERMAN_USE_CURL=FALSE -DWITHOUT_CURL=TRUE -DWITHOUT_OPENSSL=TRUE -DWITHOUT_BLKID=TRUE -DFACTER_SKIP_TESTS=TRUE -DWITHOUT_JRUBY=ON")
  elsif platform.is_windows?
    make = "#{settings[:gcc_bindir]}/mingw32-make"
    rm = '/bin/rm'
    pkg.environment "PATH", "$(shell cygpath -u #{settings[:prefix]}/lib):/cygdrive/c/ProgramData/chocolatey/bin:$(cygpath -u #{settings[:gcc_bindir]}):$(cygpath -u #{settings[:build_tools_dir]}):$(cygpath -u #{settings[:ruby_dir]}):/cygdrive/c/Windows/system32:/cygdrive/c/Windows:/cygdrive/c/Windows/System32/WindowsPowerShell/v1.0"
    pkg.environment('FACTER_CMAKE_OPTS', '-G \"MinGW Makefiles\" -DLEATHERMAN_USE_CURL=FALSE -DWITHOUT_CURL=TRUE -DWITHOUT_OPENSSL=TRUE -DWITHOUT_BLKID=TRUE -DFACTER_SKIP_TESTS=TRUE -DCMAKE_TOOLCHAIN_FILE=C:\tools\pl-build-tools\pl-build-toolchain.cmake -DWITHOUT_JRUBY=ON')
  else
    make = 'make'
    rm = 'rm'
    pkg.environment "PATH" => "#{settings[:build_tools_dir]}:#{settings[:ruby_dir]}:$$PATH"
    pkg.environment('FACTER_CMAKE_OPTS', "-DLEATHERMAN_USE_CURL=FALSE -DWITHOUT_CURL=TRUE -DWITHOUT_OPENSSL=TRUE -DWITHOUT_BLKID=TRUE -DFACTER_SKIP_TESTS=TRUE -DWITHOUT_JRUBY=ON")
  end

  if platform.is_windows?
    gemdir = "$(shell cygpath -m #{settings[:gemdir]})"
  else
    gemdir = settings[:gemdir]
  end

  pkg.configure do
    [
      "#{settings[:ruby_binary]} generate-gemspec.rb facter-precompiled.gemspec.erb \"#{gemdir}\" '#{settings[:project_version]}'"
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
