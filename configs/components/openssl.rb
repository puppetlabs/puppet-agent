component "openssl" do |pkg, settings, platform|
  pkg.version "1.0.2e"
  if platform.is_windows?
    # OpenSSL on windows is exciting
    # If we use the openssl tarball provided by upstream, we get failures when we try to unpack it.
    # The failures are fixed if we do not set CYGWIN with winsymlinks:native. However, if we do not
    # set CYGWIN with that value, even though the tarball successfully unpacks, the build itself
    # fails due to inconsistencies between the files (as a result of the symlinks being in a state
    # that cygwin/windwos cannot understand). In order to deal with this, we have to unpack and
    # repack openssl.
    #   * gunzip -c openssl.tar.gz | tar xf -
    #   * mv openssl openssl-windows
    #   * manually remove all of the symlinks so the symlink targets are the same as their sources
    #     - To do this, I removed the symlink, and copied the source file into the location where
    #       the symlink was.
    #     - These symlinks are mainly found in the test directory, though there is one in the app
    #       directory.
    #   * tar -czf openssl-windows.tar.gz openssl-windows
    # Please don't hate me, this was the best solution I could come up with :(
    pkg.md5sum "74c599905f9929f6b42658fe0f396393"
    pkg.url "http://buildsources.delivery.puppetlabs.net/openssl-#{pkg.get_version}-windows.tar.gz"
  else
    pkg.md5sum "5262bfa25b60ed9de9f28d5d52d77fc5"
    pkg.url "http://buildsources.delivery.puppetlabs.net/openssl-#{pkg.get_version}.tar.gz"
  end

  pkg.replaces 'pe-openssl'

  # Use our toolchain on linux systems (it's not available on osx)
  if platform.is_linux?
    pkg.build_requires 'pl-binutils'
    pkg.build_requires 'pl-gcc'
    if platform.name =~ /el-4/
      pkg.build_requires 'runtime'
    end
  elsif platform.is_solaris?
    if platform.os_version == "10"
      pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-gcc-4.8.2-1.#{platform.architecture}.pkg.gz"
      pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-binutils-2.25.#{platform.architecture}.pkg.gz"
    elsif platform.os_version == "11"
      pkg.build_requires "pl-gcc-#{platform.architecture}"
    end
    pkg.build_requires 'runtime'
    pkg.apply_patch 'resources/patches/openssl/add-shell-to-engines_makefile.patch'
    pkg.apply_patch 'resources/patches/openssl/openssl-1.0.0l-use-gcc-instead-of-makedepend.patch'
  elsif platform.is_aix?
    pkg.apply_patch 'resources/patches/openssl/add-shell-to-engines_makefile.patch'
    pkg.apply_patch 'resources/patches/openssl/openssl-1.0.0l-use-gcc-instead-of-makedepend.patch'
    pkg.build_requires 'runtime'
  elsif platform.is_osx?
    pkg.build_requires 'makedepend'
  elsif platform.is_windows?
    pkg.apply_patch 'resources/patches/openssl/openssl-1.0.0l-use-gcc-instead-of-makedepend.patch'
    # This patch removes the option `-DOPENSSL_USE_APPLINK` from the mingw openssl congifure target
    # This brings mingw more in line with what is happening with mingw64. All applink does it makes
    # it possible to use the .dll compiled with one compiler with an application compiled with a
    # different compiler. Given our openssl should only be interacting with things that we build,
    # we can ensure everything is build with the same compiler.
    pkg.apply_patch 'resources/patches/openssl/openssl-mingw-do-not-build-applink.patch'
    pkg.build_requires "runtime"
  end

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
  elsif platform.is_aix?
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-gcc-5.2.0-1.aix#{platform.os_version}.ppc.rpm"
    target = 'aix-gcc'
    ldflags = ''
    cflags = "$${CFLAGS} -static-libgcc"
    pkg.environment "CC" => "/opt/pl-build-tools/bin/gcc"
  elsif platform.is_windows?
    target = platform.architecture == "x64" ? "mingw64" : "mingw"
    pkg.environment "PATH" => "$$(cygpath -u #{settings[:gcc_bindir]}):$$PATH"
    pkg.environment "CYGWIN" => settings[:cygwin]
    cflags = settings[:cflags]
    ldflags = settings[:ldflags]
  else
    pkg.environment "PATH" => "/opt/pl-build-tools/bin:$$PATH:/usr/local/bin"
    if platform.architecture =~ /86$/
      target = 'linux-elf'
      sslflags = '386'
    elsif platform.architecture =~ /64$/
      target = 'linux-x86_64'
    elsif platform.architecture =~ /ppce500mc$/
      target = 'linux-ppc'
    elsif platform.architecture =~ /ppc64le$/
      target = 'linux-ppc64le'
    elsif platform.architecture =~ /s390/
      target = 'linux64-s390x'
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

  if platform.is_aix?
    pkg.install do
      ["slibclean"]
    end
  end

  install_prefix = "INSTALL_PREFIX=/" unless platform.is_windows?

  pkg.install do
    ["#{platform[:make]} #{install_prefix} install"]
  end

  pkg.install_file "LICENSE", "#{settings[:prefix]}/share/doc/openssl-#{pkg.get_version}/LICENSE"
end
