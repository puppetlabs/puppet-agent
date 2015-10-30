component "puppet-ca-bundle" do |pkg, settings, platform|
  pkg.load_from_json("configs/components/puppet-ca-bundle.json")
  pkg.build_requires "openssl"
  # facter will pull in java for server platforms, so require that so we can
  # make the keystore
  pkg.build_requires 'facter'

  pkg.install do
    "#{platform[:make]} install OPENSSL=#{settings[:bindir]}/openssl USER=0 GROUP=0 DESTDIR=#{File.join(settings[:prefix], 'ssl')}"
    "#{platform[:make]} keystore"
  end
end
