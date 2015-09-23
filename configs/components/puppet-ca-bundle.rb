component "puppet-ca-bundle" do |pkg, settings, platform|
  pkg.load_from_json("configs/components/puppet-ca-bundle.json")
  pkg.build_requires "openssl"

  pkg.install do
    ["#{platform[:make]} install OPENSSL=#{settings[:bindir]}/openssl"]
  end
end
