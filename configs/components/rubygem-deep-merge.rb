component "rubygem-deep-merge" do |pkg, settings, platform|
  pkg.version "1.0.1"
  pkg.md5sum "6f30bc4727f1833410f6a508304ab3c1"
  pkg.url "https://rubygems.org/downloads/deep_merge-#{pkg.get_version}.gem"

  pkg.replaces "pe-rubygem-deep-merge"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"

  if platform.is_windows?
    pkg.environment "PATH", "$(RUBY_BINDIR):$(PATH)"
  end

  # Because we are cross-compiling on sparc, we can't use the rubygems we just built.
  # Instead we use the host gem installation and override GEM_HOME. Yay?
  pkg.environment "GEM_HOME" => settings[:gem_home]

  # PA-25 in order to install gems in a cross-compiled environment we need to
  # set RUBYLIB to include puppet and hiera, so that their gemspecs can resolve
  # hiera/version and puppet/version requires. Without this the gem install
  # will fail by blowing out the stack.
  pkg.environment "RUBYLIB" => "#{settings[:ruby_vendordir]}:$$RUBYLIB"

  pkg.install do
    ["#{settings[:gem_install]} deep_merge-#{pkg.get_version}.gem"]
  end
end
