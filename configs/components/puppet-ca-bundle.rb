component "puppet-ca-bundle" do |pkg, settings, platform|
  pkg.load_from_json("configs/components/puppet-ca-bundle.json")

  pkg.build_requires "openssl"

  openssl_cmd = "#{settings[:bindir]}/openssl"
  if platform.is_cross_compiled_linux?
    # Use the build host's openssl command, not our cross-compiled one
    openssl_cmd = "/usr/bin/openssl"
  end

  pkg.install do
    ["#{platform[:make]} install OPENSSL=#{openssl_cmd} USER=0 GROUP=0 DESTDIR=#{File.join(settings[:prefix], 'ssl')}",
    "#{platform[:make]} keystore OPENSSL=#{openssl_cmd} DESTDIR=#{File.join(settings[:prefix], 'ssl')}"]
  end
end
