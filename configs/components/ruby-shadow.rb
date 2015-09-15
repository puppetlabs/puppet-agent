component "ruby-shadow" do |pkg, settings, platform|
  pkg.version "2.3.3"
  pkg.md5sum "c9fec6b2a18d673322a6d3d83870e122"
  pkg.url "http://buildsources.delivery.puppetlabs.net/ruby-shadow-2.3.3.tar.gz"

  pkg.replaces 'pe-ruby-shadow'

  pkg.build_requires "ruby"
  pkg.environment "PATH" => "$$PATH:/usr/ccs/bin:/usr/sfw/bin"
  pkg.environment "CONFIGURE_ARGS" => '--vendor'

  if platform.is_solaris?
    if platform.architecture == 'sparc'
      pkg.environment "RUBY" => settings[:host_ruby]
    end
    ruby = "#{settings[:host_ruby]} -r#{settings[:datadir]}/doc/rbconfig.rb"
  else
    ruby = File.join(settings[:bindir], 'ruby')
  end

  pkg.build do
     [ "#{ruby} extconf.rb",
     "#{platform[:make]} -e -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    ["#{platform[:make]} -e -j$(shell expr $(shell #{platform[:num_cores]}) + 1) DESTDIR=/ install"]
  end
end
