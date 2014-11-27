component "ruby-shadow" do |pkg, settings, platform|
  pkg.version "2.3.3"
  pkg.md5sum "c9fec6b2a18d673322a6d3d83870e122"
  pkg.url "http://buildsources.delivery.puppetlabs.net/ruby-shadow-2.3.3.tar.gz"

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
