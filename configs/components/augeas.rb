component 'augeas' do |pkg, settings, platform|
  pkg.version '1.10.1'
  pkg.md5sum '6c0b2ea6eec45e8bc374b283aedf27ce'
  pkg.url "http://download.augeas.net/augeas-#{pkg.get_version}.tar.gz"
  pkg.mirror "#{settings[:buildsources_url]}/augeas-#{pkg.get_version}.tar.gz"

  pkg.replaces 'pe-augeas'
  pkg.build_requires "libxml2"
  if platform.name =~ /^el-(5|6|7)-.*/ || platform.is_fedora?
    # Augeas needs a libselinux pkgconfig file on these platforms
    pkg.build_requires 'ruby-selinux'
  end

  # Ensure we're building against our own libraries when present
  pkg.environment "PKG_CONFIG_PATH", "/opt/puppetlabs/puppet/lib/pkgconfig"

  if platform.is_aix?
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-gcc-5.2.0-11.aix#{platform.os_version}.ppc.rpm"
    pkg.build_requires "http://osmirror.delivery.puppetlabs.net/AIX_MIRROR/pkg-config-0.19-6.aix5.2.ppc.rpm"
    pkg.environment "CC", "/opt/pl-build-tools/bin/gcc"
    pkg.environment "LDFLAGS", settings[:ldflags]
    pkg.environment "CFLAGS", "-I/opt/puppetlabs/puppet/include/"
    pkg.build_requires 'libedit'
    pkg.build_requires 'runtime'
  end

  if platform.is_rpm? && !platform.is_aix?
    pkg.build_requires 'readline-devel'
    pkg.build_requires 'pkgconfig'

    if platform.is_cisco_wrlinux?
      pkg.requires 'libreadline6'
    else
      pkg.requires 'readline'
    end

    if platform.architecture =~ /aarch64|ppc64le|s390x/
      pkg.build_requires 'runtime'
      pkg.environment "PATH", "/opt/pl-build-tools/bin:$(PATH):#{settings[:bindir]}"
      pkg.environment "CFLAGS", settings[:cflags]
      pkg.environment "LDFLAGS", settings[:ldflags]
    end
  elsif platform.is_deb?
    pkg.build_requires 'libreadline-dev'
    if platform.name =~ /debian-9/
      pkg.requires 'libreadline7'
    else
      pkg.requires 'libreadline6'
    end

    pkg.build_requires 'pkg-config'
    if platform.is_cross_compiled_linux?
      pkg.environment "PATH", "/opt/pl-build-tools/bin:$(PATH):#{settings[:bindir]}"
      pkg.environment "CFLAGS", settings[:cflags]
      pkg.environment "LDFLAGS", settings[:ldflags]
    end

  elsif platform.is_solaris?
    pkg.environment "PATH", "/opt/pl-build-tools/bin:$(PATH):/usr/local/bin:/usr/ccs/bin:/usr/sfw/bin:#{settings[:bindir]}"
    pkg.environment "CFLAGS", settings[:cflags]
    pkg.environment "LDFLAGS", settings[:ldflags]
    pkg.build_requires 'libedit'
    pkg.build_requires 'runtime'
    if platform.os_version == "10"
      pkg.build_requires 'pkgconfig'
      pkg.environment "PKG_CONFIG_PATH", "/opt/csw/lib/pkgconfig"
      pkg.environment "PKG_CONFIG", "/opt/csw/bin/pkg-config"
    else
      pkg.build_requires 'pl-pkg-config'
      pkg.environment "PKG_CONFIG_PATH", "/usr/lib/pkgconfig"
      pkg.environment "PKG_CONFIG", "/opt/pl-build-tools/bin/pkg-config"
    end
  elsif platform.is_macos?
    pkg.environment "PATH" => "$(PATH):/usr/local/bin"
    pkg.environment "CFLAGS" => settings[:cflags]
  end

  pkg.configure do
    ["./configure --prefix=#{settings[:prefix]} #{settings[:host]}"]
  end

  if platform.name =~ /solaris-10-sparc/
    # This patch to gnulib fixes a linking error around symbol versioning in pthread.
    pkg.add_source 'file://resources/patches/augeas/augeas-1.10.1-gnulib-pthread-in-use.patch'

    pkg.configure do
      # gnulib is a submodule, and its files don't exist until after configure,
      # so we apply the patch manually here instead of using pkg.apply_patch.
      ["/usr/bin/gpatch -p0 < ../augeas-1.10.1-gnulib-pthread-in-use.patch"]
    end
  end

  pkg.build do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install"]
  end
end
