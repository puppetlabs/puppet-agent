component "libxml2" do |pkg, settings, platform|
  pkg.version "2.9.2"
  pkg.md5sum "9e6a9aca9d155737868b3dc5fd82f788"
  pkg.url "http://buildsources.delivery.puppetlabs.net/#{pkg.get_name}-#{pkg.get_version}.tar.gz"

  pkg.build_requires "pl-gcc"
  pkg.build_requires "make"
  pkg.build_requires "python"
  pkg.environment "LDFLAGS" => "-Wl,-rpath=#{settings[:libdir]} -L#{settings[:libdir]}"
  pkg.environment "CFLAGS" => "$${CFLAGS} -fPIC"

  pkg.configure do
    ["./configure --prefix=#{settings[:prefix]}"]
  end

  pkg.build do
    ["#{platform[:make]} VERBOSE=1 -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    ["#{platform[:make]} VERBOSE=1 -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install"]
  end

end
