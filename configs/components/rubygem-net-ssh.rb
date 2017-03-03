component "rubygem-net-ssh" do |pkg, settings, platform|
  pkg.version "2.9.2"
  pkg.md5sum "ac7574a89e2b422468d98f5387ceb41e"
  pkg.url "https://rubygems.org/downloads/net-ssh-#{pkg.get_version}.gem"

  pkg.replaces 'pe-rubygem-net-ssh'

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
    ["#{settings[:gem_install]} net-ssh-#{pkg.get_version}.gem"]
  end
end
