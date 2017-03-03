component "rubygem-net-scp" do |pkg, settings, platform|
  pkg.version "1.2.1"
  pkg.md5sum "abeec1cab9696e02069e74bd3eac8a1b"
  pkg.url "https://rubygems.org/downloads/net-scp-#{pkg.get_version}.gem"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"
  pkg.build_requires "rubygem-net-ssh"

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
    ["#{settings[:gem_install]} net-scp-#{pkg.get_version}.gem"]
  end
end
