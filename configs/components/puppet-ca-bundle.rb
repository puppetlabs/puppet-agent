component "puppet-ca-bundle" do |pkg, settings, platform|
  pkg.load_from_json("configs/components/puppet-ca-bundle.json")
  pkg.build_requires "openssl"
  # facter will pull in java for server platforms, so require that so we can
  # make the keystore
  pkg.build_requires 'facter'

  if platform.is_windows?
    pkg.environment "PATH" => "#{settings[:gcc_bindir]}:#{settings[:bindir]}:$$PATH"
    sslpath = platform.convert_to_windows_path(File.join(settings[:bindir], "openssl"))
    ssl_certspath = platform.convert_to_windows_path(File.join(settings[:puppet_configdir], "ssl"))

    # We need to use cygwin make for the makefile to run correctly
    make = "/usr/bin/make"
  else
    sslpath = "#{settings[:bindir]}/openssl"
    ssl_certspath = File.join(settings[:prefix], 'ssl')
    make = platform[:make]
  end

  install_commands = [
    "#{make} install OPENSSL=#{sslpath} USER=0 GROUP=0 DESTDIR=#{ssl_certspath}"
  ]

  if settings[:java_available]
    install_commands << "#{make} keystore DESTDIR=#{ssl_certspath}"
  end

  pkg.install do
    install_commands
  end
end
