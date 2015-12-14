component 'curl' do |pkg, settings, platform|
  pkg.version '7.46.0'
  pkg.md5sum '230e682d59bf8ab6eca36da1d39ebd75'
  pkg.url "http://buildsources.delivery.puppetlabs.net/curl-#{pkg.get_version}.tar.gz"

  pkg.build_requires "openssl"

  prefix = settings[:prefix]
  pem_file = "#{settings[:prefix]}/ssl/cert.pem"

  make = platform[:make]

  if platform.is_windows?
    pkg.build_requires "pl-zlib-#{platform.architecture}"
    pkg.build_requires "runtime"

    pkg.environment "PATH" => "#{settings[:gcc_bindir]}:$$PATH"
    pkg.environment "CYGWIN" => settings[:cygwin]
    pkg.environment "CC" => settings[:cc]
    pkg.environment "CXX" => settings[:cxx]

    prefix = platform.convert_to_windows_path(settings[:prefix])
    pem_file = platform.convert_to_windows_path("#{settings[:puppet_configdir]}/ssl/cert.pem")

    make = "/usr/bin/make"
  end

  pkg.configure do
    ["LDFLAGS='#{settings[:ldflags]}' \
     ./configure --prefix=#{prefix} \
        --with-ssl=#{prefix} \
        --enable-threaded-resolver \
        --disable-ldap \
        --disable-ldaps \
        --with-ca-bundle=#{pem_file} \
        #{settings[:host]}"]
  end

  pkg.build do
    ["#{make} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    ["#{make} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install"]
  end
end
