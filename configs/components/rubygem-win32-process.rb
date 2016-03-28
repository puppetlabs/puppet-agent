component "rubygem-win32-process" do |pkg, settings, platform|
  pkg.version "0.7.4"
  pkg.md5sum "3231cf152383fb2d792dcac8036b060f"
  pkg.url "http://buildsources.delivery.puppetlabs.net/win32-process-#{pkg.get_version}.gem"

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
    ["#{settings[:gem_install]} win32-process-#{pkg.get_version}.gem"]
  end
end
