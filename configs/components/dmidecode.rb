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

  # BSD install will explode with find errors on solaris, so we use ginstall instead.
  if platform.is_solaris?
    pkg.environment "PATH" => "$$PATH:/opt/csw/bin:/usr/ccs/bin:/usr/sfw/bin"
    pkg.environment "INSTALL" => "ginstall"
  end

  # -e is required to ensure that the exports make it into the make environment.
  pkg.build do
    ["#{platform[:make]} -e -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    ["#{platform[:make]} -e prefix=#{settings[:prefix]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install"]
  end
end

