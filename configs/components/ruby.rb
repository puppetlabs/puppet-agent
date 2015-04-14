component "ruby" do |pkg, settings, platform|
  pkg.version "2.1.5"
  pkg.md5sum "df4c1b23f624a50513c7a78cb51a13dc"
  pkg.url "http://buildsources.delivery.puppetlabs.net/ruby-2.1.5.tar.gz"

  pkg.provides "pe-#{pkg.get_name}", pkg.get_version
  pkg.provides "pe-rubygems"
  pkg.provides "/opt/puppet/bin/ruby"
  pkg.provides "pe-libyaml"

  pkg.replaces "pe-#{pkg.get_name}", '2.1.5'
  pkg.replaces "pe-rubygems"
  pkg.replaces "pe-libyaml"
  pkg.replaces "pe-libldap", "2.4.40"
  pkg.replaces "pe-ruby-ldap", "0.9.13"


  pkg.apply_patch "resources/patches/ruby/libyaml_cve-2014-9130.patch"

  pkg.build_requires "openssl"

  if platform.is_deb?
    pkg.build_requires "zlib1g-dev"
  elsif platform.is_rpm?
    pkg.build_requires "zlib-devel"
  end

  pkg.configure do
    ["./configure \
        --prefix=#{settings[:prefix]} \
        --with-opt-dir=#{settings[:prefix]} \
        --enable-shared \
        --disable-install-rdoc"]
  end

  pkg.build do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install"]
  end
end
