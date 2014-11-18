component "facter" do |pkg, settings, platform|
  pkg.version "2.2.0.2"
  pkg.md5sum "fcf9600d3656f0c455784b1659439ff8"
  pkg.url "http://builds.puppetlabs.lan/pe-facter/2.2.0.2/repos/pe-facter-2.2.0.2.tar.gz"

  pkg.depends_on "ruby"

  pkg.install do
    ["#{settings[:bindir]}/ruby install.rb --sitelibdir=#{settings[:ruby_vendordir]} --quick --man --mandir=#{settings[:mandir]}"]
  end
end
