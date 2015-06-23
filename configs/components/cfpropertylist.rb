component "cfpropertylist" do |pkg, settings, platform|
  pkg.version "2.2.7"
  pkg.md5sum "be2fc619084422cc28cb68f6084bea91"
  pkg.url "http://buildsources.delivery.puppetlabs.net/CFPropertyList-2.2.7.tar.gz"

  pkg.build_requires "ruby"

  pkg.install do
    ["cp -pr lib/* #{settings[:ruby_vendordir]}"]
  end
end
