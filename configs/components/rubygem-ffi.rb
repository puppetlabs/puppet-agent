component "rubygem-ffi" do |pkg, settings, platform|
  pkg.version "1.9.18"

  if platform.is_windows?
    if platform.architecture == "x64"
      pkg.md5sum "664afc6a316dd648f497fbda3be87137"
      pkg.url "https://rubygems.org/downloads/ffi-#{pkg.get_version}-x64-mingw32.gem"
    else
      pkg.md5sum "0b6fd994826952231d285f078cefce32"
      pkg.url "https://rubygems.org/downloads/ffi-#{pkg.get_version}-x86-mingw32.gem"
    end

    pkg.build_requires "ruby-#{settings[:ruby_version]}"

    # Because we are cross-compiling on sparc, we can't use the rubygems we just built.
    # Instead we use the host gem installation and override GEM_HOME. Yay?
    pkg.environment "GEM_HOME" => settings[:gem_home]

    pkg.environment "PATH" => "$$(cygpath -u #{settings[:gcc_bindir]}):$$(cygpath -u #{settings[:ruby_bindir]}):$$(cygpath -u #{settings[:bindir]}):/cygdrive/c/Windows/system32:/cygdrive/c/Windows:/cygdrive/c/Windows/System32/WindowsPowerShell/v1.0"

    # PA-25 in order to install gems in a cross-compiled environment we need to
    # set RUBYLIB to include puppet and hiera, so that their gemspecs can resolve
    # hiera/version and puppet/version requires. Without this the gem install
    # will fail by blowing out the stack.
    pkg.environment "RUBYLIB" => "#{settings[:ruby_vendordir]}:$$RUBYLIB"

    pkg.install do
      ["#{settings[:gem_install]} ffi-#{pkg.get_version}-#{platform.architecture}-mingw32.gem"]
    end
  end
end
