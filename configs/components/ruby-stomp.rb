component "ruby-stomp" do |pkg, settings, platform|
  pkg.version "1.3.3"
  pkg.md5sum "50a2c1b66982b426d67a83f56f4bc0e2"
  pkg.url "https://rubygems.org/downloads/stomp-#{pkg.get_version}.gem"

  pkg.replaces 'pe-ruby-stomp'

  pkg.build_requires "ruby-#{settings[:ruby_version]}"

  # Because we are cross-compiling on sparc, we can't use the rubygems we just built.
  # Instead we use the host gem installation and override GEM_HOME. Yay?
  pkg.environment "GEM_HOME", settings[:gem_home]

  if platform.is_windows?
    pkg.environment "PATH", "$(RUBY_BINDIR):$(PATH)"
  end

  # PA-25 in order to install gems in a cross-compiled environment we need to
  # set RUBYLIB to include puppet and hiera, so that their gemspecs can resolve
  # hiera/version and puppet/version requires. Without this the gem install
  # will fail by blowing out the stack.
  pkg.environment "RUBYLIB", "#{settings[:ruby_vendordir]}:$$RUBYLIB"

  base = 'resources/patches/ruby-stomp'
  pkg.apply_patch "#{base}/verify_client_certs.patch", destination: "#{settings[:gem_home]}/gems/stomp-#{pkg.get_version}", after: "install"

  pkg.install do
    ["#{settings[:gem_install]} stomp-#{pkg.get_version}.gem"]
  end
end
