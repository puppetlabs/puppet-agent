component "ruby-stomp" do |pkg, settings, platform|
  pkg.version "1.3.3"
  pkg.md5sum "50a2c1b66982b426d67a83f56f4bc0e2"
  pkg.url "http://buildsources.delivery.puppetlabs.net/stomp-1.3.3.gem"

  pkg.build_requires "ruby"

  pkg.install do
    [ "#{settings[:bindir]}/gem install --no-rdoc --no-ri stomp-1.3.3.gem"]
  end
end
