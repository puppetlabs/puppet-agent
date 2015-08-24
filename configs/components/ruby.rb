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

  # Cross-compiles require a hand-built rbconfig from the target system
  if platform.architecture == "sparc"
    pkg.add_source "file://resources/files/rbconfig-#{settings[:platform_triple]}.rb", sum: "e3ce52e22c49b7a32eb290b6253b0cbc"
  end

  # Required only on el4 so far
  pkg.apply_patch "resources/patches/ruby/ruby-no-stack-protector.patch" if platform.name =~ /el-4/

  # This is needed for date_core to correctly compile on solaris 10. Breaks gem installations.
  pkg.apply_patch "resources/patches/ruby/fix-date-compilation.patch" if platform.is_solaris?

  pkg.build_requires "openssl"

  if platform.is_deb?
    pkg.build_requires "zlib1g-dev"
  elsif platform.is_rpm?
    pkg.build_requires "zlib-devel"
  end

  if platform.is_solaris?
    if platform.architecture == "sparc"
      # ruby1.8 is not new enough to successfully cross-compile ruby 2.1.6 (it doesn't understand the --disable-gems flag)
      pkg.build_requires 'ruby19'
      special_flags = "--with-baseruby=/opt/csw/bin/ruby"
    end
    pkg.build_requires 'libedit'
    pkg.build_requires 'runtime'
    pkg.environment "PATH" => "#{settings[:bindir]}:/usr/ccs/bin:/usr/sfw/bin:$$PATH"
    pkg.environment "CC" => "/opt/pl-build-tools/bin/#{settings[:platform_triple]}-gcc"
    pkg.environment "LDFLAGS" => "-Wl,-rpath=/opt/puppetlabs/puppet/lib"
  end

  # Here we set --enable-bundled-libyaml to ensure that the libyaml included in
  # ruby is used, even if the build system has a copy of libyaml available
  pkg.configure do
    ["./configure \
        --prefix=#{settings[:prefix]} \
        --with-opt-dir=#{settings[:prefix]} \
        --enable-shared \
        --enable-bundled-libyaml \
        --disable-install-doc \
        --disable-install-rdoc \
        #{settings[:host]} \
        #{special_flags}"]
  end

  pkg.build do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    [
      "#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install",
    ]
  end

  if platform.architecture == "sparc"
    # Here we replace the rbconfig from our cross-compile with an rbconfig from a native sparc ruby build so that
    # gem installs on a user system will actually work
    pkg.install do
      [
        "/opt/csw/bin/gsed -i 's|raise|warn|g' /opt/puppetlabs/puppet/lib/ruby/2.1.0/sparc-solaris2.10/rbconfig.rb",
        "mkdir -p #{settings[:datadir]}/doc",
        "cp /opt/puppetlabs/puppet/lib/ruby/2.1.0/sparc-solaris2.10/rbconfig.rb #{settings[:datadir]}/doc",
        "cp ../rbconfig-#{settings[:platform_triple]}.rb /opt/puppetlabs/puppet/lib/ruby/2.1.0/sparc-solaris2.10",
      ]
    end
  end
end
