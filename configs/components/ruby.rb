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

  base = 'resources/patches/ruby'
  pkg.apply_patch "#{base}/libyaml_cve-2014-9130.patch"
  pkg.apply_patch "#{base}/CVE-2015-4020.patch"

  if platform.is_aix?
    pkg.apply_patch "#{base}/aix_ruby_2.1_libpath_with_opt_dir.patch"
    pkg.apply_patch "#{base}/aix_ruby_2.1_fix_proctitle.patch"
    pkg.apply_patch "#{base}/aix_ruby_2.1_fix_make_test_failure.patch"
    pkg.environment "CC" => "/opt/pl-build-tools/bin/gcc"
    pkg.environment "LDFLAGS" =>  settings[:ldflags]
    pkg.build_requires "libedit"
    pkg.build_requires "runtime"
  end

  # Cross-compiles require a hand-built rbconfig from the target system
  if platform.is_solaris?
    rbconfig_info = {
      'i386-pc-solaris2.10' => {
        :sum => "5a34dbec6d4b8dbe1a01dedfc60441aa",
        :target_double => 'i386-solaris2.10',
      },
      'sparc-sun-solaris2.10' => {
        :sum => "e3ce52e22c49b7a32eb290b6253b0cbc",
        :target_double => 'sparc-solaris2.10',
      },
      'i386-pc-solaris2.11' => {
        :sum => "bf62b4ad7b3f74299f7b3f5a0a819798",
        :target_double => 'i386-solaris2.11',
      },
      'sparc-sun-solaris2.11' => {
        :sum => "a699015beb45b4bc5065d69b4610d326",
        :target_double => 'sparc-solaris2.11',
      }
    }

    pkg.add_source "file://resources/files/rbconfig-#{settings[:platform_triple]}.rb", sum: rbconfig_info[settings[:platform_triple]][:sum]
  end

  # This is needed for date_core to correctly compile on solaris 10. Breaks gem installations.
  pkg.apply_patch "resources/patches/ruby/fix-date-compilation.patch" if platform.is_solaris?

  pkg.build_requires "openssl"

  if platform.is_deb?
    pkg.build_requires "zlib1g-dev"
  elsif platform.is_aix?
    pkg.build_requires "http://osmirror.delivery.puppetlabs.net/AIX_MIRROR/zlib-devel-1.2.3-4.aix5.2.ppc.rpm"
  elsif platform.is_rpm?
    pkg.build_requires "zlib-devel"
  end

  if platform.is_solaris?
    if platform.architecture == "sparc"
      if platform.os_version == "10"
        # ruby1.8 is not new enough to successfully cross-compile ruby 2.1.x (it doesn't understand the --disable-gems flag)
        pkg.build_requires 'ruby19'
      elsif platform.os_version == "11"
        pkg.build_requires 'pl-ruby'
      end

      special_flags = "--with-baseruby=#{settings[:host_ruby]}"
    end
    pkg.build_requires 'libedit'
    pkg.build_requires 'runtime'
    pkg.environment "PATH" => "#{settings[:bindir]}:/usr/ccs/bin:/usr/sfw/bin:$$PATH:/opt/csw/bin"
    pkg.environment "CC" => "/opt/pl-build-tools/bin/#{settings[:platform_triple]}-gcc"
    pkg.environment "LDFLAGS" => "-Wl,-rpath=/opt/puppetlabs/puppet/lib"
  end

  # Here we set --enable-bundled-libyaml to ensure that the libyaml included in
  # ruby is used, even if the build system has a copy of libyaml available
  pkg.configure do
    [
      "./configure \
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

  if platform.is_solaris?
    # Here we replace the rbconfig from our ruby compiled with our toolchain
    # with an rbconfig from a ruby of the same version compiled with the system
    # gcc. Without this, the rbconfig will be looking for a gcc that won't
    # exist on a user system and will also pass flags which may not work on
    # that system.
    # We also disable a safety check in the rbconfig to prevent it from being
    # loaded from a different ruby, because we're going to do that later to
    # install compiled gems.
    target_dir = File.join(settings[:libdir], "ruby", "2.1.0", rbconfig_info[settings[:platform_triple]][:target_double])
    pkg.install do
      [
        "gsed -i 's|raise|warn|g' #{target_dir}/rbconfig.rb",
        "mkdir -p #{settings[:datadir]}/doc",
        "cp #{target_dir}/rbconfig.rb #{settings[:datadir]}/doc",
        "cp ../rbconfig-#{settings[:platform_triple]}.rb #{target_dir}/rbconfig.rb",
      ]
    end
  end
end
