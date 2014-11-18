component "hiera" do |pkg, settings, platform|
  pkg.version "1.3.4.1"
  pkg.md5sum "ad228c8af8b471b60621e5b1cb9d10f6"
  pkg.url "http://builds.puppetlabs.lan/pe-hiera/1.3.4.1/artifacts/pe-hiera-1.3.4.1.tar.gz"

  pkg.depends_on "ruby"
  pkg.depends_on "rubygem-deep-merge"

  pkg.install do
    ["#{settings[:bindir]}/ruby install.rb --configdir=#{settings[:sysconfdir]} --sitelibdir=#{settings[:ruby_vendordir]} --configs --quick --man --mandir=#{settings[:mandir]}"]
  end
end
