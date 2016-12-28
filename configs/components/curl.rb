component 'curl' do |pkg, settings, platform|
  pkg.version '7.51.0'
  pkg.md5sum '490e19a8ccd1f4a244b50338a0eb9456'
  pkg.url "https://curl.haxx.se/download/curl-#{pkg.get_version}.tar.gz"

  pkg.build_requires "openssl"
  pkg.build_requires "puppet-ca-bundle"

  if platform.is_cross_compiled_linux?
    pkg.build_requires 'runtime'
    pkg.environment "CC" => "/opt/pl-build-tools/bin/#{settings[:platform_triple]}-gcc"
    pkg.environment "PKG_CONFIG_PATH" => "/opt/puppetlabs/puppet/lib/pkgconfig"
    pkg.environment "PATH" => "/opt/pl-build-tools/bin:$$PATH"
  end

  if platform.is_windows?
    pkg.build_requires "runtime"

    pkg.environment "PATH" => "$$(cygpath -u #{settings[:gcc_bindir]}):$$PATH"
    pkg.environment "CYGWIN" => settings[:cygwin]
  end

  pkg.configure do
    ["CPPFLAGS='#{settings[:cppflags]}' \
      LDFLAGS='#{settings[:ldflags]}' \
     ./configure --prefix=#{settings[:prefix]} \
        --with-ssl=#{settings[:prefix]} \
        --enable-threaded-resolver \
        --disable-ldap \
        --disable-ldaps \
        --with-ca-bundle=#{settings[:prefix]}/ssl/cert.pem \
        #{settings[:host]}"]
  end

  pkg.build do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install"]
  end
end
