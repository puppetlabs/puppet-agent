component "rubygem-mini_portile2" do |pkg, settings, platform|
  pkg.version "2.0.0"
  pkg.md5sum "e608463ac8081fe600f7bb6ea46c3e64"
  pkg.url "http://buildsources.delivery.puppetlabs.net/mini_portile2-#{pkg.get_version}.gem"

  pkg.build_requires "ruby"

  # When cross-compiling, we can't use the rubygems we just built.
  # Instead we use the host gem installation and override GEM_HOME. Yay?
  pkg.environment "GEM_HOME" => settings[:gem_home]

  # PA-25 in order to install gems in a cross-compiled environment we need to
  # set RUBYLIB to include puppet and hiera, so that their gemspecs can resolve
  # hiera/version and puppet/version requires. Without this the gem install
  # will fail by blowing out the stack.
  pkg.environment "RUBYLIB" => "#{settings[:ruby_vendordir]}:$$RUBYLIB"

  pkg.install do
    ["#{settings[:gem_install]} mini_portile2-#{pkg.get_version}.gem"]
  end
end
