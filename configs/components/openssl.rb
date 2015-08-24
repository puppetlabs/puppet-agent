component "openssl" do |pkg, settings, platform|
  pkg.version "1.0.2d"
  pkg.md5sum "38dd619b2e77cbac69b99f52a053d25a"
  pkg.url "http://buildsources.delivery.puppetlabs.net/openssl-#{pkg.get_version}.tar.gz"

  pkg.replaces 'pe-openssl'

  # Use our toolchain here. It's not available on osx, so only include it on linux systems.
  if platform.is_linux?
    pkg.build_requires 'pl-binutils'
    pkg.build_requires 'pl-gcc'
  elsif platform.is_solaris?
    pkg.build_requires 'runtime'
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-gcc-4.8.2.#{platform.architecture}.pkg.gz"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-binutils-2.25.#{platform.architecture}.pkg.gz"

    pkg.apply_patch 'resources/patches/openssl/add-shell-to-engines_makefile.patch'
    pkg.apply_patch 'resources/patches/openssl/openssl-1.0.0l-use-gcc-instead-of-makedepend.patch'
  elsif platform.is_osx?
    pkg.build_requires 'makedepend'
  end

  ca_certfile = File.join(settings[:prefix], 'ssl', 'cert.pem')

  if platform.is_osx?
    pkg.environment "PATH" => "/opt/pl-build-tools/bin:$$PATH:/usr/local/bin"
    target = 'darwin64-x86_64-cc'
    cflags = settings[:cflags]
    ldflags = ''
  elsif platform.is_solaris?
    pkg.environment "PATH" => "/opt/pl-build-tools/bin:$$PATH:/usr/local/bin:/usr/ccs/bin:/usr/sfw/bin"
    pkg.environment "CC" => "/opt/pl-build-tools/bin/#{settings[:platform_triple]}-gcc"
    if platform.architecture =~ /86/
      target = 'solaris-x86-gcc'
    else
      target = 'solaris-sparcv9-gcc'
    end

    ldflags = "-R/opt/pl-build-tools/#{settings[:platform_triple]}/lib -Wl,-rpath=#{settings[:libdir]} -L/opt/pl-build-tools/#{settings[:platform_triple]}/lib"
    cflags = "#{settings[:cflags]} -fPIC"
  else
    pkg.environment "PATH" => "/opt/pl-build-tools/bin:$$PATH:/usr/local/bin"
    if platform.architecture =~ /86$/
      target = 'linux-elf'
      sslflags = '386'
    elsif platform.architecture =~ /64$/
      target = 'linux-x86_64'
    end
    cflags = settings[:cflags]
    ldflags = "#{settings[:ldflags]} -Wl,-z,relro"
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
      no-asm \
      #{target} \
      #{sslflags} \
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
      #{cflags} \
      #{ldflags}"]
  end

  pkg.build do
    ["#{platform[:make]} depend",
    "#{platform[:make]}"]
  end

  pkg.install do
    ["#{platform[:make]} INSTALL_PREFIX=/ install"]
  end

  pkg.install_file "LICENSE", "#{settings[:prefix]}/share/doc/openssl-#{pkg.get_version}/LICENSE"

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
