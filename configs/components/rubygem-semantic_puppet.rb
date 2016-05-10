component "rubygem-semantic_puppet" do |pkg, settings, platform|
  pkg.version "0.1.2"
  pkg.md5sum "192ae7729997cb5d5364f64b99b13121"
  pkg.url "http://buildsources.delivery.puppetlabs.net/semantic_puppet-#{pkg.get_version}.gem"

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
    ["#{settings[:gem_install]} semantic_puppet-#{pkg.get_version}.gem"]
  end
end
