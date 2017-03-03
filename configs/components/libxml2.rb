component "libxml2" do |pkg, settings, platform|
  pkg.version "2.9.4"
  pkg.md5sum "ae249165c173b1ff386ee8ad676815f5"
  pkg.url "http://xmlsoft.org/sources/#{pkg.get_name}-#{pkg.get_version}.tar.gz"

  if platform.is_aix?
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-gcc-5.2.0-1.aix#{platform.os_version}.ppc.rpm"
  elsif platform.is_cross_compiled_linux?
    pkg.environment "PATH", "#{settings[:bindir]}:$(PATH)"
    pkg.environment "CFLAGS" => settings[:cflags]
    pkg.environment "LDFLAGS" => settings[:ldflags]
  elsif platform.is_solaris?
    pkg.environment "PATH", ":#{settings[:bindir]}:$(PATH):/usr/local/bin:/usr/ccs/bin:/usr/sfw/bin"
    pkg.environment "CFLAGS" => settings[:cflags]
    pkg.environment "LDFLAGS" => settings[:ldflags]
  elsif platform.is_macos?
    pkg.environment "LDFLAGS" => settings[:ldflags]
    pkg.environment "CFLAGS" => settings[:cflags]
  else
    pkg.build_requires "pl-gcc"
    pkg.build_requires "make"
    pkg.environment "LDFLAGS" => settings[:ldflags]
    pkg.environment "CFLAGS" => settings[:cflags]
  end

  if platform.is_cross_compiled? && platform.is_deb?
    pkg.build_requires "pl-pkg-config"
  end

  if platform.is_cross_compiled_linux? || platform.name =~ /solaris-11/
    pkg.build_requires "pl-gcc-#{platform.architecture}"
  end

  pkg.configure do
    ["./configure --prefix=#{settings[:prefix]} --without-python #{settings[:host]}"]
  end

  pkg.build do
    ["#{platform[:make]} VERBOSE=1 -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    [
      "#{platform[:make]} VERBOSE=1 -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install",
      "rm -rf #{settings[:datadir]}/gtk-doc",
      "rm -rf #{settings[:datadir]}/doc/#{pkg.get_name}*"
    ]
  end

end
