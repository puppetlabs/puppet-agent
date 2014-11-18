component "ruby-augeas" do |pkg, settings, platform|
  pkg.version "0.5.0"
  pkg.md5sum "a132eace43ce13ccd059e22c0b1188ac"
  pkg.url "http://buildsources.delivery.puppetlabs.net/ruby-augeas-0.5.0.tgz"

  pkg.depends_on "ruby"
  pkg.depends_on "augeas"

  pkg.build do
    ["export CONFIGURE_ARGS='--vendor'",
     "export CFLAGS=#{platform[:cflags]}",
     "export PKG_CONFIG_PATH=#{settings[:libdir]}/pkgconfig",
     "#{settings[:bindir]}/ruby ext/augeas/extconf.rb",
     platform[:make]]
  end

  pkg.install do
    ["#{platform[:make]} DESTDIR=/ install",
     "install -d #{settings[:ruby_vendordir]}",
     "cp -pr lib/augeas.rb #{settings[:ruby_vendordir]}"]
  end
end
