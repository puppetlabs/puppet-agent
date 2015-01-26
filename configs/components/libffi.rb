component "libffi" do |pkg, settings, platform|
  pkg.version "3.2.1"
  pkg.md5sum "83b89587607e3eb65c70d361f13bab43"
  pkg.url "http://buildsources.delivery.puppetlabs.net/libffi-#{pkg.get_version}.tar.gz"

  pkg.configure do
    ["./configure --prefix=#{settings[:prefix]} --disable-static"]
  end

  pkg.build do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install"]
  end
end
