component "ruby-augeas" do |pkg, settings, platform|
  pkg.version "0.5.0"
  pkg.md5sum "a132eace43ce13ccd059e22c0b1188ac"
  pkg.url "http://buildsources.delivery.puppetlabs.net/ruby-augeas-0.5.0.tgz"

  pkg.replaces 'pe-ruby-augeas'

  pkg.build_requires "ruby"
  pkg.build_requires "augeas"

  pkg.environment "PATH" => "$$PATH:/opt/pl-build-tools/bin:/usr/local/bin:/opt/csw/bin:/usr/ccs/bin:/usr/sfw/bin"
  pkg.environment "CONFIGURE_ARGS" => '--vendor'
  pkg.environment "PKG_CONFIG_PATH" => "#{File.join(settings[:libdir], 'pkgconfig')}:/usr/lib/pkgconfig"

  if platform.is_solaris?
    if platform.architecture == 'sparc'
      ruby = "/opt/csw/bin/ruby -r#{settings[:datadir]}/doc/rbconfig.rb"
      pkg.environment "RUBY" => "/opt/csw/bin/ruby"
    else
      ruby = "#{File.join(settings[:bindir], 'ruby')} -r#{settings[:datadir]}/doc/rbconfig.rb"
    end
  else
    ruby = File.join(settings[:bindir], 'ruby')
  end

  pkg.build do
     [ "#{ruby} ext/augeas/extconf.rb",
       "#{platform[:make]} -e -j$(shell expr $(shell #{platform[:num_cores]}) + 1)" ]
  end

  pkg.install_file 'lib/augeas.rb', File.join(settings[:ruby_vendordir], 'augeas.rb')
  pkg.install do
    [
      "#{platform[:make]} -e -j$(shell expr $(shell #{platform[:num_cores]}) + 1) DESTDIR=/ install",
    ]
  end

  pkg.install do
    "chown root:root #{settings[:ruby_vendordir]}/augeas.rb"
  end if platform.is_solaris?

end
