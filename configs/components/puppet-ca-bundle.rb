component "puppet-ca-bundle" do |pkg, settings, platform|
  pkg.load_from_json("configs/components/puppet-ca-bundle.json")
  pkg.build_requires "openssl"
  # facter will pull in java for server platforms, so require that so we can
  # make the keystore
  pkg.build_requires 'facter'

  openssl_cmd = "#{settings[:bindir]}/openssl"
  if platform.is_cross_compiled_linux?
    # Use the build host's openssl command, not our cross-compiled one
    openssl_cmd = "/usr/bin/openssl"
  end

  install_commands = [
    "#{platform[:make]} install OPENSSL=#{openssl_cmd} USER=0 GROUP=0 DESTDIR=#{File.join(settings[:prefix], 'ssl')}"
  ]

  if settings[:java_available]
    install_commands << "#{platform[:make]} keystore OPENSSL=#{openssl_cmd} DESTDIR=#{File.join(settings[:prefix], 'ssl')}"
  end

  pkg.install do
    install_commands
  end
end
