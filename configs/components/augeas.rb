component 'augeas' do |pkg, settings, platform|
  pkg.version '1.4.0'
  pkg.md5sum 'a2536a9c3d744dc09d234228fe4b0c93'
  pkg.url "http://download.augeas.net/augeas-#{pkg.get_version}.tar.gz"

  pkg.replaces 'pe-augeas'
  pkg.apply_patch 'resources/patches/augeas/osx-stub-needed-readline-functions.patch'
  pkg.apply_patch 'resources/patches/augeas/sudoers-negated-command-alias.patch'
  pkg.apply_patch 'resources/patches/augeas/src-pathx.c-parse_name-correctly-handle-trailing-ws.patch'
  if platform.is_sles? && platform.os_version == '10'
    pkg.apply_patch 'resources/patches/augeas/augeas-1.2.0-fix-services-sles10.patch'
  end

  pkg.build_requires "libxml2"

  # Ensure we're building against our own libraries when present
  pkg.environment "PKG_CONFIG_PATH" => "/opt/puppetlabs/puppet/lib/pkgconfig"

  if platform.is_aix?
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-gcc-5.2.0-11.aix#{platform.os_version}.ppc.rpm"
    pkg.build_requires "http://osmirror.delivery.puppetlabs.net/AIX_MIRROR/pkg-config-0.19-6.aix5.2.ppc.rpm"
    pkg.environment "CC" => "/opt/pl-build-tools/bin/gcc"
    pkg.environment "LDFLAGS" => settings[:ldflags]
    pkg.environment "CFLAGS" => "-I/opt/puppetlabs/puppet/include/"
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
      pkg.environment "PATH" => "/opt/pl-build-tools/bin:$$PATH:#{settings[:bindir]}"
      pkg.environment "CFLAGS" => settings[:cflags]
      pkg.environment "LDFLAGS" => settings[:ldflags]
    end
  elsif platform.is_huaweios?
    pkg.build_requires 'runtime'
    pkg.build_requires 'pl-pkg-config'

    pkg.environment "PATH" => "/opt/pl-build-tools/bin:$$PATH:#{settings[:bindir]}"
    pkg.environment "CFLAGS" => settings[:cflags]
    pkg.environment "LDFLAGS" => settings[:ldflags]
    pkg.environment "PKG_CONFIG" => "/opt/pl-build-tools/bin/pkg-config"
  elsif platform.is_deb?
    pkg.build_requires 'libreadline-dev'
    if platform.name =~ /debian-9/
      pkg.requires 'libreadline7'
    else
      pkg.requires 'libreadline6'
    end

    pkg.build_requires 'pkg-config'
    if platform.is_cross_compiled_linux?
      pkg.environment "PATH" => "/opt/pl-build-tools/bin:$$PATH:#{settings[:bindir]}"
      pkg.environment "CFLAGS" => settings[:cflags]
      pkg.environment "LDFLAGS" => settings[:ldflags]
    end

  elsif platform.is_solaris?
    pkg.environment "PATH" => "/opt/pl-build-tools/bin:$$PATH:/usr/local/bin:/usr/ccs/bin:/usr/sfw/bin:#{settings[:bindir]}"
    pkg.environment "CFLAGS" => settings[:cflags]
    pkg.environment "LDFLAGS" => settings[:ldflags]
    pkg.build_requires 'libedit'
    pkg.build_requires 'runtime'
    if platform.os_version == "10"
      pkg.build_requires 'pkgconfig'
      pkg.environment "PKG_CONFIG_PATH" => "/opt/csw/lib/pkgconfig"
      pkg.environment "PKG_CONFIG" => "/opt/csw/bin/pkg-config"
    else
      pkg.build_requires 'pl-pkg-config'
      pkg.environment "PKG_CONFIG_PATH" => "/usr/lib/pkgconfig"
      pkg.environment "PKG_CONFIG" => "/opt/pl-build-tools/bin/pkg-config"
    end
  elsif platform.is_osx?
    pkg.environment "PATH" => "$$PATH:/usr/local/bin"
    pkg.environment "CFLAGS" => settings[:cflags]
  end

  pkg.configure do
    ["./configure --prefix=#{settings[:prefix]} #{settings[:host]}"]
  end

  pkg.build do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install"]
  end
end
