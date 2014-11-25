component "ruby-shadow" do |pkg, settings, platform|
  pkg.version "2.2.0"
  pkg.md5sum "11cddd40138172899b9cfc275e5272ed"
  pkg.url "http://buildsources.delivery.puppetlabs.net/ruby-shadow-2.2.0.tar.gz"

  pkg.build_requires "ruby"

  pkg.build do
    ["export CONFIGURE_ARGS='--vendor'",
     "export CFLAGS=#{settings[:cflags]}",
     "#{settings[:bindir]}/ruby extconf.rb",
     platform[:make]]
  end

  pkg.install do
    ["#{platform[:make]} DESTDIR=/ install"]
  end
end
