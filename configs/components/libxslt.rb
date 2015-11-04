component "libxslt" do |pkg, settings, platform|
  pkg.version "1.1.28"
  pkg.md5sum "9667bf6f9310b957254fdcf6596600b7"
  pkg.url "http://buildsources.delivery.puppetlabs.net/#{pkg.get_name}-#{pkg.get_version}.tar.gz"

  pkg.build_requires "pl-gcc"
  pkg.build_requires "make"
  pkg.build_requires "libxml2"
  pkg.environment "LDFLAGS" => "-Wl,-rpath=#{settings[:libdir]} -L#{settings[:libdir]}"
  pkg.environment "CFLAGS" => "$${CFLAGS} -fPIC"

  if platform.is_deb?
    pkg.build_requires "python-dev"
  else
    pkg.build_requires "python-devel"
  end

  pkg.configure do
    [ "./configure --prefix=#{settings[:prefix]}" ]
  end

  pkg.build do
    [ "#{platform[:make]} VERBOSE=1 -j$(shell expr $(shell #{platform[:num_cores]}) + 1)" ]
  end

  pkg.install do
    [ "#{platform[:make]} VERBOSE=1 -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install" ]
  end

end
