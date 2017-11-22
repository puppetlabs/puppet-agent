component "rubygem-net-ssh-telnet2" do |pkg, settings, platform|
  pkg.version "0.1.1"
  pkg.md5sum "8fba7aada691a0c10caf5b74f57cfef2"
  pkg.url "https://rubygems.org/downloads/net-ssh-telnet2-#{pkg.get_version}.gem"
  pkg.mirror "#{settings[:buildsources_url]}/net-ssh-telnet2-#{pkg.get_version}.gem"

  pkg.build_requires "ruby"
  pkg.build_requires "rubygem-net-ssh"

  # When cross-compiling, we can't use the rubygems we just built.
  # Instead we use the host gem installation and override GEM_HOME. Yay?
  pkg.environment "GEM_HOME", settings[:gem_home]

  # PA-25 in order to install gems in a cross-compiled environment we need to
  # set RUBYLIB to include puppet and hiera, so that their gemspecs can resolve
  # hiera/version and puppet/version requires. Without this the gem install
  # will fail by blowing out the stack.
  pkg.environment "RUBYLIB", "#{settings[:ruby_vendordir]}:$(RUBYLIB)"

  pkg.install do
    ["#{settings[:gem_install]} net-ssh-telnet2-#{pkg.get_version}.gem"]
  end
end
