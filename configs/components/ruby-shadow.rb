component "ruby-shadow" do |pkg, settings, platform|
  pkg.version "2.3.3"
  pkg.md5sum "c9fec6b2a18d673322a6d3d83870e122"
  # I am unable to find ruby-shadow-2.3.3 source anywhere other than our own website. Upstream appears to be dead.
  pkg.url "https://downloads.puppetlabs.com/enterprise/sources/3.8.3/solaris/11/source/ruby-shadow-#{pkg.get_version}.tar.gz"

  pkg.replaces 'pe-ruby-shadow'

  pkg.build_requires "ruby-#{settings[:ruby_version]}"
  pkg.environment "PATH", "$(PATH):/usr/ccs/bin:/usr/sfw/bin"
  pkg.environment "CONFIGURE_ARGS", '--vendor'

  if platform.is_solaris?
    if platform.architecture == 'sparc'
      pkg.environment "RUBY", settings[:host_ruby]
    end
    ruby = "#{settings[:host_ruby]} -r#{settings[:datadir]}/doc/rbconfig.rb"
  elsif platform.is_cross_compiled_linux?
    pkg.environment "RUBY", settings[:host_ruby]
    ruby = "#{settings[:host_ruby]} -r#{settings[:datadir]}/doc/rbconfig.rb"
  else
    ruby = File.join(settings[:bindir], 'ruby')
  end

  # This is a disturbing workaround needed for s390x based systems, that
  # for some reason isn't encountered with our other architecture cross
  # builds. When trying to build the libshadow test cases for extconf.rb,
  # the process fails with "/opt/pl-build-tools/bin/s390x-linux-gnu-gcc:
  # error while loading shared libraries: /opt/puppetlabs/puppet/lib/libstdc++.so.6:
  # ELF file data encoding not little-endian". It will also complain in
  # the same way about libgcc. If however we temporarily move these
  # libraries out of the way, extconf.rb and the cross-compile work
  # properly. This needs to be fixed, but I've spent over a week analyzing
  # every possible angle that could cause this, from rbconfig settings to
  # strace logs, and we need to move forward on this platform.
  # FIXME: Scott Garman Jun 2016
  if platform.architecture == "s390x"
    pkg.configure do
      [
        "mkdir #{settings[:libdir]}/hide",
        "mv #{settings[:libdir]}/libstdc* #{settings[:libdir]}/hide/",
        "mv #{settings[:libdir]}/libgcc* #{settings[:libdir]}/hide/"
      ]
    end
  end

  pkg.build do
    ["#{ruby} extconf.rb",
     "#{platform[:make]} -e -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    ["#{platform[:make]} -e -j$(shell expr $(shell #{platform[:num_cores]}) + 1) DESTDIR=/ install"]
  end

  # Undo the gross hack from the configure step
  if platform.architecture == "s390x"
    pkg.install do
      [
        "mv #{settings[:libdir]}/hide/* #{settings[:libdir]}/",
        "rmdir #{settings[:libdir]}/hide/"
      ]
    end
  end
end
