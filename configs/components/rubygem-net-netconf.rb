component "rubygem-net-netconf" do |pkg, settings, platform|
  pkg.version "0.4.3"
  pkg.url "https://rubygems.org/downloads/net-netconf-#{get_version}.gem"
  pkg.md5sum "fa173b0965766a427d8692f6b31c85a4"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"
  pkg.build_requires "rubygem-net-scp"
  # We're force installing the gem to workaround issues we have with
  # the nokogiri gem, so there is no build_requires on rubygem-nokogiri

  # When cross-compiling, we can't use the rubygems we just built.
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
    ["#{settings[:gem_install]} --force net-netconf-#{pkg.get_version}.gem"]
  end
end
