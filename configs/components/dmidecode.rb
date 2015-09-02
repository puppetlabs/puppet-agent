component 'dmidecode' do |pkg, settings, platform|
  pkg.version '2.12'
  pkg.md5sum '02ee243e1ecac7fe0d04428aec85f63a'
  pkg.url "http://buildsources.delivery.puppetlabs.net/dmidecode-#{pkg.get_version}.tar.gz"

  pkg.apply_patch "resources/patches/dmidecode/dmidecode-1.173.patch"
  pkg.apply_patch "resources/patches/dmidecode/dmidecode-1.175.patch"
  pkg.apply_patch "resources/patches/dmidecode/dmidecode-1.176.patch"
  pkg.apply_patch "resources/patches/dmidecode/dmidecode-1.177.patch"
  pkg.apply_patch "resources/patches/dmidecode/dmidecode-1.181.patch"
  pkg.apply_patch "resources/patches/dmidecode/dmidecode-1.182.patch"
  pkg.apply_patch "resources/patches/dmidecode/dmidecode-1.195.patch"

  pkg.build do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    ["#{platform[:make]} prefix=#{settings[:prefix]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install"]
  end
end

