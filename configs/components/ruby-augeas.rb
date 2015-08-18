component "ruby-augeas" do |pkg, settings, platform|
  pkg.version "0.5.0"
  pkg.md5sum "a132eace43ce13ccd059e22c0b1188ac"
  pkg.url "http://buildsources.delivery.puppetlabs.net/ruby-augeas-0.5.0.tgz"

  pkg.replaces 'pe-ruby-augeas'

  pkg.build_requires "ruby"
  pkg.build_requires "augeas"

  pkg.environment "PATH" => "$$PATH:/usr/local/bin:/opt/csw/bin:/usr/ccs/bin:/usr/sfw/bin"
  pkg.environment "CONFIGURE_ARGS" => '--vendor'
  pkg.environment "CFLAGS" => settings[:cflags]
  pkg.environment "PKG_CONFIG_PATH" => File.join(settings[:libdir], 'pkgconfig')

  pkg.build do
     [ "#{settings[:bindir]}/ruby ext/augeas/extconf.rb",
       "#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)" ]
  end

  pkg.install_file 'lib/augeas.rb', File.join(settings[:ruby_vendordir], 'augeas.rb')
  pkg.install do
    [
      "#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) DESTDIR=/ install",
    ]
  end

  pkg.install do
    "chown root:root #{settings[:ruby_vendordir]}/augeas.rb"
  end if platform.is_solaris?

end
