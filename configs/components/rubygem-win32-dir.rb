component "rubygem-win32-dir" do |pkg, settings, platform|
  pkg.version "0.4.9"
  pkg.md5sum "df14aa01bd6011f4b6332a05e15b7fb8"
  pkg.url "https://rubygems.org/downloads/win32-dir-#{pkg.get_version}.gem"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"

  # Because we are cross-compiling on sparc, we can't use the rubygems we just built.
  # Instead we use the host gem installation and override GEM_HOME. Yay?
  pkg.environment "GEM_HOME" => settings[:gem_home]

  if platform.is_windows?
    pkg.environment "PATH", "$(RUBY_BINDIR):$(PATH)"
  end

  # PA-25 in order to install gems in a cross-compiled environment we need to
  # set RUBYLIB to include puppet and hiera, so that their gemspecs can resolve
  # hiera/version and puppet/version requires. Without this the gem install
  # will fail by blowing out the stack.
  pkg.environment "RUBYLIB" => "#{settings[:ruby_vendordir]}:$$RUBYLIB"

  pkg.install do
    ["#{settings[:gem_install]} win32-dir-#{pkg.get_version}.gem"]
  end
end
