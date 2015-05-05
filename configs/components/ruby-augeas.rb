component "ruby-augeas" do |pkg, settings, platform|
  pkg.version "0.5.0"
  pkg.md5sum "a132eace43ce13ccd059e22c0b1188ac"
  pkg.url "http://buildsources.delivery.puppetlabs.net/ruby-augeas-0.5.0.tgz"

  pkg.build_requires "ruby"
  pkg.build_requires "augeas"

  pkg.build do
    ["export PATH=$$PATH:/usr/local/bin", 
     "export CONFIGURE_ARGS='--vendor'",
     "export CFLAGS=#{settings[:cflags]}",
     "export PKG_CONFIG_PATH=#{settings[:libdir]}/pkgconfig",
     "#{settings[:bindir]}/ruby ext/augeas/extconf.rb",
     "#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) DESTDIR=/ install",
     "install -d #{settings[:ruby_vendordir]}",
     "cp -pr lib/augeas.rb #{settings[:ruby_vendordir]}"]
  end
end
