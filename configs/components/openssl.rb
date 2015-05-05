component "openssl" do |pkg, settings, platform|
  pkg.version "1.0.0r"
  pkg.md5sum "ea48d0ad53e10f06a9475d8cdc209dfa"
  pkg.url "http://buildsources.delivery.puppetlabs.net/openssl-#{pkg.get_version}.tar.gz"

  ca_certfile = File.join(settings[:prefix], 'ssl', 'cert.pem')

  case platform.name
  when /^osx-.*$/
    target = 'darwin64-x86_64-cc'
    ldflags = ''
  else
    target = 'linux-elf'
    ldflags = "#{settings[:ldflags]} -Wl,-z,relro"
  end

  if platform.is_osx?
    pkg.apply_patch 'resources/patches/openssl/openssl-1.0.0l-use-gcc-instead-of-makedepend.patch'
  end

  pkg.configure do
    [# OpenSSL Configure doesn't honor CFLAGS or LDFLAGS as environment variables.
    # Instead, those should be passed to Configure at the end of its options, as
    # any unrecognized options are passed straight through to ${CC}. Defining
    # --libdir ensures that we avoid the multilib (lib/ vs. lib64/) problem,
    # since configure uses the existence of a lib64 directory to determine
    # if it should install its own libs into a multilib dir. Yay OpenSSL!
    "./Configure \
      --prefix=#{settings[:prefix]} \
      --libdir=lib \
      --openssldir=#{settings[:prefix]}/ssl \
      shared \
      #{target} \
      no-asm 386 \
      no-camellia \
      enable-seed \
      enable-tlsext \
      enable-rfc3779 \
      enable-cms \
      no-md2 \
      no-mdc2 \
      no-rc5 \
      no-ec2m \
      no-gost \
      no-srp \
      no-ssl2 \
      no-ssl3 \
      #{settings[:cflags]}
      #{ldflags}"]
  end

  pkg.build do
    ["#{platform[:make]} depend",
    "#{platform[:make]}"]
  end

  pkg.install do
    ["#{platform[:make]} INSTALL_PREFIX=/ install"]
  end

  if platform.is_deb?
    pkg.link '/etc/ssl/certs/ca-certificates.crt', ca_certfile
  elsif platform.is_rpm?
    case platform[:name]
    when /sles-10-.*$/, /sles-11-.*$/
      pkg.install do
        "pushd '#{settings[:prefix]}/ssl/certs' 2>&1 >/dev/null; find /etc/ssl/certs -type f -a -name '\*pem' -print0 | xargs -0 --no-run-if-empty -n1 ln -sf; #{settings[:prefix]}/bin/c_rehash ."
      end
    when /sles-12-.*$/
      pkg.link '/etc/ssl/ca-bundle.pem', ca_certfile
    when /el-4-.*$/
      pkg.link '/usr/share/ssl/certs/ca-bundle.crt', ca_certfile
    else
      pkg.link '/etc/pki/tls/certs/ca-bundle.crt', ca_certfile
    end
  end
end
