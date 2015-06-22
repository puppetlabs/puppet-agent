component 'curl' do |pkg, settings, platform|
  pkg.version '7.42.1'
  pkg.md5sum '8df5874c4a67ad55496bf3af548d99a2'
  pkg.url "http://buildsources.delivery.puppetlabs.net/curl-#{pkg.get_version}.tar.gz"

  pkg.build_requires "openssl"

  pkg.configure do
    ["LDFLAGS='#{settings[:ldflags]}' \
     ./configure --prefix=#{settings[:prefix]} \
     --with-ssl=#{settings[:prefix]} --enable-threaded-resolver --disable-ldap --disable-ldaps"]
  end

  pkg.build do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install"]
  end
end
