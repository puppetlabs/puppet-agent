component 'augeas' do |pkg, settings, platform|
  pkg.version '1.4.0'
  pkg.md5sum 'a2536a9c3d744dc09d234228fe4b0c93'
  pkg.url "http://buildsources.delivery.puppetlabs.net/#{pkg.get_name}-#{pkg.get_version}.tar.gz"

  pkg.replaces 'pe-augeas'

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
    ["PATH=$$PATH:/usr/local/bin \
     ./configure --prefix=#{settings[:prefix]}"]
  end

  pkg.build do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install"]
  end
end
