component "openssl" do |pkg, settings, platform|
  pkg.version "1.0.2n"
  pkg.md5sum "13bdc1b1d1ff39b6fd42a255e74676a4"
  pkg.url "https://openssl.org/source/openssl-#{pkg.get_version}.tar.gz"
  pkg.mirror "#{settings[:buildsources_url]}/openssl-#{pkg.get_version}.tar.gz"

  pkg.replaces 'pe-openssl'
  unless platform.name =~ /debian-9-armhf/
    pkg.build_requires 'runtime'
  end

  # Use our toolchain on linux systems (it's not available on osx)
  if platform.is_cross_compiled_linux?
    # needed for the makedepend command
    pkg.build_requires 'imake' if platform.name =~ /^el/
    pkg.build_requires 'xorg-x11-util-devel' if platform.name =~ /^sles/
    pkg.build_requires 'xutils-dev' if platform.is_deb?
  elsif platform.is_linux?
    unless (platform.is_fedora? && platform.os_version.delete('f').to_i >= 26) or platform !~ /debian-9-armhf/
      pkg.build_requires 'pl-binutils'
    end
    unless platform.name =~ /debian-9-armhf/
      pkg.build_requires 'pl-gcc'
    end

    if platform.name =~ /debian-[8|9]-arm/
      pkg.build_requires "xutils-dev"
      pkg.apply_patch 'resources/patches/openssl/openssl-1.0.0l-use-gcc-instead-of-makedepend.patch'
    end
  elsif platform.is_solaris?
    pkg.apply_patch 'resources/patches/openssl/add-shell-to-engines_makefile.patch'
    pkg.apply_patch 'resources/patches/openssl/openssl-1.0.0l-use-gcc-instead-of-makedepend.patch'
  elsif platform.is_aix?
    pkg.apply_patch 'resources/patches/openssl/add-shell-to-engines_makefile.patch'
    pkg.apply_patch 'resources/patches/openssl/openssl-1.0.0l-use-gcc-instead-of-makedepend.patch'
  elsif platform.is_macos?
    pkg.build_requires 'makedepend'
  elsif platform.is_windows?
    pkg.apply_patch 'resources/patches/openssl/openssl-1.0.0l-use-gcc-instead-of-makedepend.patch'
    # This patch removes the option `-DOPENSSL_USE_APPLINK` from the mingw openssl congifure target
    # This brings mingw more in line with what is happening with mingw64. All applink does it makes
    # it possible to use the .dll compiled with one compiler with an application compiled with a
    # different compiler. Given our openssl should only be interacting with things that we build,
    # we can ensure everything is build with the same compiler.
    pkg.apply_patch 'resources/patches/openssl/openssl-mingw-do-not-build-applink.patch'
  end

  if platform.is_macos?
    pkg.environment "PATH", "/opt/pl-build-tools/bin:$(PATH):/usr/local/bin"
    target = 'darwin64-x86_64-cc'
    cflags = settings[:cflags]
    ldflags = ''
  elsif platform.is_cross_compiled_linux?
    pkg.environment "PATH", "/opt/pl-build-tools/bin:$$PATH"
    pkg.environment "CC", "/opt/pl-build-tools/bin/#{settings[:platform_triple]}-gcc"

    cflags = "#{settings[:cflags]} -fPIC"
    ldflags = "-Wl,-rpath=/opt/pl-build-tools/#{settings[:platform_triple]}/lib -Wl,-rpath=#{settings[:libdir]} -L/opt/pl-build-tools/#{settings[:platform_triple]}/lib"

    if platform.name =~ /debian-9-armhf/
      pkg.environment "CC", "/usr/bin/arm-linux-gnueabihf-gcc-6"
      ldflags = ""
    end

    if platform.is_huaweios?
      ldflags = "-R/opt/pl-build-tools/#{settings[:platform_triple]}/lib -Wl,-rpath=#{settings[:libdir]} -L/opt/pl-build-tools/#{settings[:platform_triple]}/lib"
      target = 'linux-ppc'
    elsif platform.architecture == "aarch64"
      target = 'linux-aarch64'
    elsif platform.name =~ /debian-[8|9]-arm/
      target = 'linux-armv4'
    elsif platform.architecture =~ /ppc64/
      target = 'linux-ppc64le'
    elsif platform.architecture == "s390x"
      target = 'linux64-s390x'
    end
  elsif platform.is_solaris?
    pkg.environment "PATH", "/opt/pl-build-tools/bin:$(PATH):/usr/local/bin:/usr/ccs/bin:/usr/sfw/bin"
    pkg.environment "CC", "/opt/pl-build-tools/bin/#{settings[:platform_triple]}-gcc"
    if platform.architecture =~ /86/
      target = 'solaris-x86-gcc'
    else
      target = 'solaris-sparcv9-gcc'
    end

    ldflags = "-R/opt/pl-build-tools/#{settings[:platform_triple]}/lib -Wl,-rpath=#{settings[:libdir]} -L/opt/pl-build-tools/#{settings[:platform_triple]}/lib"
    cflags = "#{settings[:cflags]} -fPIC"
  elsif platform.is_aix?
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-gcc-5.2.0-11.aix#{platform.os_version}.ppc.rpm"
    target = 'aix-gcc'
    ldflags = ''
    cflags = "$${CFLAGS} -static-libgcc"
    pkg.environment "CC", "/opt/pl-build-tools/bin/gcc"
  elsif platform.is_windows?
    target = platform.architecture == "x64" ? "mingw64" : "mingw"
    pkg.environment "PATH", "$(shell cygpath -u #{settings[:gcc_bindir]}):$(PATH)"
    pkg.environment "CYGWIN", settings[:cygwin]
    cflags = settings[:cflags]
    ldflags = settings[:ldflags]
  else
    pkg.environment "PATH", "/opt/pl-build-tools/bin:$(PATH):/usr/local/bin"
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
    # Below will disable: bf, camellia, gost, idea, md2/4, rc2/5, seed, srp
    "./Configure \
      --prefix=#{settings[:prefix]} \
      --libdir=lib \
      --openssldir=#{settings[:prefix]}/ssl \
      shared \
      no-asm \
      #{target} \
      #{sslflags} \
      no-camellia \
      enable-tlsext \
      enable-rfc3779 \
      no-md2 \
      no-mdc2 \
      no-weak-ssl-ciphers \
      no-dtls \
      no-dtls1 \
      no-idea \
      no-seed \
      no-ec2m \
      no-ssl2 \
      no-ssl2-method \
      no-ssl3 \
      -DOPENSSL_NO_HEARTBEATS \
      #{cflags} \
      #{ldflags}"]
  end

  pkg.build do
    ["#{platform[:make]} depend",
    "#{platform[:make]}"]
  end

  if platform.is_aix?
    pkg.install do
      ["slibclean"]
    end
  end

  install_prefix = "INSTALL_PREFIX=/" unless platform.is_windows?

  pkg.install do
    ["#{platform[:make]} #{install_prefix} install_sw"]
  end

  pkg.install_file "LICENSE", "#{settings[:prefix]}/share/doc/openssl-#{pkg.get_version}/LICENSE"
end
