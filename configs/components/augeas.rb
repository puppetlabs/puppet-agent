component 'augeas' do |pkg, settings, platform|
  pkg.version '1.3.0'
  pkg.md5sum 'c8890b11a04795ecfe5526eeae946b2d'
  pkg.url "http://buildsources.delivery.puppetlabs.net/#{pkg.get_name}-#{pkg.get_version}.tar.gz"

  pkg.provides 'pe-augeas', '1.3.0'
  pkg.replaces 'pe-augeas', '1.3.0'

  if platform.is_rpm?
    pkg.build_requires 'libxml2-devel'
    pkg.requires 'libxml2'

    pkg.build_requires 'readline-devel'
    if platform.is_nxos?
      pkg.requires 'libreadline6'
    else
      pkg.requires 'readline'
    end

    pkg.build_requires 'pkgconfig'
  elsif platform.is_deb?
    pkg.build_requires 'libxml2-dev'
    pkg.requires 'libxml2'

    pkg.build_requires 'libreadline-dev'
    pkg.requires 'libreadline6'

    pkg.build_requires 'pkg-config'
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
