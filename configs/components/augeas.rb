component "augeas" do |pkg, settings, platform|
  pkg.version "1.3.0"
  pkg.md5sum "c8890b11a04795ecfe5526eeae946b2d"
  pkg.url "http://buildsources.delivery.puppetlabs.net/#{pkg.get_name}-#{pkg.get_version}.tar.gz"

  if platform.is_rpm?
    pkg.build_requires "libxml2-devel"
    pkg.build_requires "pkgconfig"
    pkg.build_requires "readline-devel"
  elsif platform.is_deb?
    pkg.build_requires "libxml2-dev"
    pkg.build_requires "libreadline-dev"
  end

  pkg.configure do
    ["./configure --prefix=#{settings[:prefix]}"]
  end

  pkg.build do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install"]
  end
end
