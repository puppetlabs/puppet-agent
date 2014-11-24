component "ruby-stomp" do |pkg, settings, platform|
  pkg.version "1.3.3"
  pkg.md5sum "803344d3291a3fc3daa7da67b318165a"
  pkg.url "http://buildsources.delivery.puppetlabs.net/stomp-1.3.3.tar.gz"

  pkg.depends_on "ruby"

  pkg.install do
    ["install -d -m0755 #{settings[:ruby_vendordir]}",
     "install -d -m0755 #{settings[:bindir]}",
     "cp -pr lib/* #{settings[:ruby_vendordir]}",
     "cp -pr bin/* #{settings[:bindir]}"]
  end
end
