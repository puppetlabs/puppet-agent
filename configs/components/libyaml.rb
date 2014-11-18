component "libyaml" do |pkg, settings, platform|
  pkg.version "0.1.6"
  pkg.md5sum "5fe00cda18ca5daeb43762b80c38e06e"
  pkg.url "http://buildsources.delivery.puppetlabs.net/yaml-0.1.6.tar.gz"

  pkg.environment do
    { "INSTALL" => "install -p" }
  end

  pkg.configure do
    ["./configure --prefix=#{settings[:prefix]} --enable-shared"]
  end

  pkg.build do
    ["#{platform[:make]}"]
  end

  pkg.install do
    ["#{platform[:make]} install"]
  end
end
