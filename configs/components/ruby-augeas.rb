component "ruby-augeas" do |pkg, settings, platform|
  pkg.version "0.5.0"
  pkg.md5sum "a132eace43ce13ccd059e22c0b1188ac"
  pkg.url "http://download.augeas.net/ruby/ruby-augeas-#{pkg.get_version}.tgz"
  pkg.mirror "#{settings[:buildsources_url]}/ruby-augeas-#{pkg.get_version}.tar.gz"

  pkg.replaces 'pe-ruby-augeas'

  pkg.build_requires "ruby-#{settings[:ruby_version]}"
  pkg.build_requires "augeas"

  pkg.environment "PATH", "$(PATH):/opt/pl-build-tools/bin:/usr/local/bin:/opt/csw/bin:/usr/ccs/bin:/usr/sfw/bin"
  if platform.is_aix?
    pkg.build_requires "http://osmirror.delivery.puppetlabs.net/AIX_MIRROR/pkg-config-0.19-6.aix5.2.ppc.rpm"
    pkg.environment "CC", "/opt/pl-build-tools/bin/gcc"
    pkg.environment "RUBY", "/opt/puppetlabs/puppet/bin/ruby"
    pkg.environment "LDFLAGS", " -brtl #{settings[:ldflags]}"
  end

  pkg.environment "CONFIGURE_ARGS", '--vendor'
  pkg.environment "PKG_CONFIG_PATH", "#{File.join(settings[:libdir], 'pkgconfig')}:/usr/lib/pkgconfig"

  if platform.is_solaris?
    if platform.architecture == 'sparc'
      pkg.environment "RUBY", settings[:host_ruby]
    end
    ruby = "#{settings[:host_ruby]} -r#{settings[:datadir]}/doc/rbconfig.rb"
  elsif platform.is_cross_compiled_linux?
    pkg.environment "RUBY", settings[:host_ruby]
    ruby = "#{settings[:host_ruby]} -r#{settings[:datadir]}/doc/rbconfig.rb"
    pkg.environment "LDFLAGS", settings[:ldflags]
  else
    ruby = File.join(settings[:bindir], 'ruby')
  end

  # This is a disturbing workaround needed for s390x based systems, that
  # for some reason isn't encountered with our other architecture cross
  # builds. When trying to build the augeas test cases for extconf.rb,
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
    ["#{ruby} ext/augeas/extconf.rb",
       "#{platform[:make]} -e -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install_file 'lib/augeas.rb', File.join(settings[:ruby_vendordir], 'augeas.rb')
  pkg.install do
    [
      "#{platform[:make]} -e -j$(shell expr $(shell #{platform[:num_cores]}) + 1) DESTDIR=/ install",
    ]
  end

  pkg.install do
    "chown root:root #{settings[:ruby_vendordir]}/augeas.rb"
  end if platform.is_solaris? || platform.is_cross_compiled_linux?

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
