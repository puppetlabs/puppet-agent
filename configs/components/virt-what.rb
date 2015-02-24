component "virt-what" do |pkg, settings, platform|
  pkg.version "1.1.4"
  pkg.md5sum "4d9bb5afc81de31f66443d8674bb3672"
  pkg.url "#{settings[:mirror_url]}virt-what-1.14.tar.gz"

  # Run-time requirements
  unless platform.is_deb?
    requires "util-linux"
  end
  unless ( platform.name =~ /^el-4-.*$/ or platform.name =~ /^sles-(10|11)-.*$/ )
    requires "dmidecode"
  end
  if platform.name =~ /^sles-(10|11)-.*$/
    requires "pmtools"
  end

  if platform.is_rpm?
    pkg.build_requires "util-linux"
  end

  pkg.configure do
    ["./configure --prefix=#{settings[:prefix]} --sbindir=#{settings[:prefix]}/bin --libexecdir=#{settings[:prefix]}/lib/virt-what"]
  end

  pkg.build do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install"]
  end
end
