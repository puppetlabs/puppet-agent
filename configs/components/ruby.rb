component "ruby" do |pkg, settings, platform|
  pkg.version "2.1.6"
  pkg.md5sum "6e5564364be085c45576787b48eeb75f"
  pkg.url "http://buildsources.delivery.puppetlabs.net/ruby-#{pkg.get_version}.tar.gz"

  pkg.replaces 'pe-ruby'
  pkg.replaces 'pe-rubygems'
  pkg.replaces 'pe-libyaml'
  pkg.replaces 'pe-libldap'
  pkg.replaces 'pe-ruby-ldap'
  pkg.replaces 'pe-rubygem-gem2rpm'

  pkg.apply_patch "resources/patches/ruby/libyaml_cve-2014-9130.patch"
  pkg.apply_patch "resources/patches/ruby/CVE-2015-4020.patch"

  # Required only on el4 so far
  pkg.apply_patch "resources/patches/ruby/ruby-no-stack-protector.patch" if platform.name =~ /el-4/

  pkg.build_requires "openssl"

  env = "PATH=/opt/pl-build-tools/bin:$$PATH"
  env += " CFLAGS='#{settings[:cflags]}' LDFLAGS='#{settings[:ldflags]}'" if platform.is_linux?

  if platform.is_deb?
    pkg.build_requires "zlib1g-dev"
  elsif platform.is_rpm?
    pkg.build_requires "zlib-devel"
  end

  pkg.configure do
    ["#{env} ./configure \
        --prefix=#{settings[:prefix]} \
        --with-opt-dir=#{settings[:prefix]} \
        --enable-shared \
        --disable-install-doc"]
  end

  pkg.build do
    ["#{env} #{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    ["#{env} #{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install"]
  end
end
