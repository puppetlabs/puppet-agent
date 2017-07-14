component "rubygem-semantic_puppet" do |pkg, settings, platform|
  pkg.version "0.1.2"
  pkg.md5sum "192ae7729997cb5d5364f64b99b13121"
  pkg.url "https://rubygems.org/downloads/semantic_puppet-#{pkg.get_version}.gem"
  pkg.mirror "http://buildsources.delivery.puppetlabs.net/semantic_puppet-#{pkg.get_version}.gem"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"

  # Because we are cross-compiling on sparc, we can't use the rubygems we just built.
  # Instead we use the host gem installation and override GEM_HOME. Yay?
  pkg.environment "GEM_HOME", settings[:gem_home]

  if platform.is_windows?
    pkg.environment "PATH", "$(shell cygpath -u #{settings[:gcc_bindir]}):$(shell cygpath -u #{settings[:ruby_bindir]}):$(shell cygpath -u #{settings[:bindir]}):/cygdrive/c/Windows/system32:/cygdrive/c/Windows:/cygdrive/c/Windows/System32/WindowsPowerShell/v1.0"
  end

  # PA-25 in order to install gems in a cross-compiled environment we need to
  # set RUBYLIB to include puppet and hiera, so that their gemspecs can resolve
  # hiera/version and puppet/version requires. Without this the gem install
  # will fail by blowing out the stack.
  pkg.environment "RUBYLIB", "#{settings[:ruby_vendordir]}:$(RUBYLIB)"

  pkg.install do
    ["#{settings[:gem_install]} semantic_puppet-#{pkg.get_version}.gem"]
  end
end
