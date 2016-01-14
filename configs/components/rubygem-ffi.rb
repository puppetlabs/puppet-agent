component "rubygem-ffi" do |pkg, settings, platform|
  pkg.version "1.9.6"

  if platform.is_windows?
    if platform.architecture == "x64"
      pkg.md5sum "daf0d310a5c498906f94f8c10006fd39"
      pkg.url "http://buildsources.delivery.puppetlabs.net/ffi-#{pkg.get_version}-x64-mingw32.gem"
    else
      pkg.md5sum "5a0b3f3602f65a2b7fe6569a3333a068"
      pkg.url "http://buildsources.delivery.puppetlabs.net/ffi-#{pkg.get_version}-x86-mingw32.gem"
    end

    pkg.build_requires "ruby"

    # Because we are cross-compiling on sparc, we can't use the rubygems we just built.
    # Instead we use the host gem installation and override GEM_HOME. Yay?
    pkg.environment "GEM_HOME" => settings[:gem_home]

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
