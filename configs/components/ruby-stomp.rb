component "ruby-stomp" do |pkg, settings, platform|
  pkg.version "1.2.9"
  pkg.md5sum "6bc97daafeae143816f9999a189cb5dc"
  pkg.url "http://buildsources.delivery.puppetlabs.net/stomp-1.2.9.tar.gz"

  pkg.depends_on "ruby"

  pkg.install do
    ["install -d -m0755 #{settings[:ruby_vendordir]}",
     "install -d -m0755 #{settings[:bindir]}",
     "cp -pr lib/* #{settings[:ruby_vendordir]}",
     "cp -pr bin/* #{settings[:bindir]}"]
  end
end
