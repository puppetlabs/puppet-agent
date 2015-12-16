component "rubygem-win32-security" do |pkg, settings, platform|
  pkg.version "0.2.5"
  pkg.md5sum "97c4b971ea19ca48cea7dec1d21d506a"
  pkg.url "http://buildsources.delivery.puppetlabs.net/win32-security-#{pkg.get_version}.gem"

  pkg.build_requires "ruby"

  pkg.environment "PATH" => "#{settings[:bindir]}:$$PATH"

  # Because we are cross-compiling on sparc, we can't use the rubygems we just built.
  # Instead we use the host gem installation and override GEM_HOME. Yay?
  if platform.is_windows?
    pkg.environment "GEM_HOME" => platform.convert_to_windows_path(settings[:gem_home])
  else
    pkg.environment "GEM_HOME" => settings[:gem_home]
  end

  # PA-25 in order to install gems in a cross-compiled environment we need to
  # set RUBYLIB to include puppet and hiera, so that their gemspecs can resolve
  # hiera/version and puppet/version requires. Without this the gem install
  # will fail by blowing out the stack.
  pkg.environment "RUBYLIB" => "#{settings[:ruby_vendordir]}:$$RUBYLIB"

  pkg.install do
    ["#{settings[:gem_install]} win32-security-#{pkg.get_version}.gem"]
  end
end
