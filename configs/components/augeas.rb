component 'augeas' do |pkg, settings, platform|
  pkg.version '1.4.0'
  pkg.md5sum 'a2536a9c3d744dc09d234228fe4b0c93'
  pkg.url "http://buildsources.delivery.puppetlabs.net/#{pkg.get_name}-#{pkg.get_version}.tar.gz"

  pkg.replaces 'pe-augeas'
  pkg.apply_patch 'resources/patches/augeas/osx-stub-needed-readline-functions.patch'
  pkg.apply_patch 'resources/patches/augeas/sudoers-negated-command-alias.patch'
  if platform.is_sles? && platform.os_version == '10'
    pkg.apply_patch 'resources/patches/augeas/augeas-1.2.0-fix-services-sles10.patch'
  end

  if platform.is_aix?
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-gcc-5.2.0-1.aix#{platform.os_version}.ppc.rpm"
    pkg.build_requires "http://osmirror.delivery.puppetlabs.net/AIX_MIRROR/pkg-config-0.19-6.aix5.2.ppc.rpm"
    pkg.build_requires "http://osmirror.delivery.puppetlabs.net/AIX_MIRROR/libxml2-2.6.21-4.aix5.2.ppc.rpm"
    pkg.build_requires "http://osmirror.delivery.puppetlabs.net/AIX_MIRROR/libxml2-devel-2.6.21-4.aix5.2.ppc.rpm"
    pkg.environment "CC" => "/opt/pl-build-tools/bin/gcc"
    pkg.environment "LDFLAGS" => settings[:ldflags]
    pkg.environment "CFLAGS" => "-I/opt/puppetlabs/puppet/include/"
    pkg.build_requires 'libedit'
    pkg.build_requires 'runtime'
  end

  if platform.is_rpm? && !platform.is_aix?
    pkg.build_requires 'libxml2-devel'
    pkg.requires 'libxml2'

    pkg.build_requires 'readline-devel'
    if platform.is_nxos? || platform.is_cisco_wrlinux? || platform.is_huaweios?
      pkg.requires 'libreadline6'
    else
      pkg.requires 'readline'
    end

    if platform.name =~ /el-4/
      pkg.build_requires 'runtime'
    end

    pkg.build_requires 'pkgconfig'
  elsif platform.is_deb?
    pkg.build_requires 'libxml2-dev'
    pkg.requires 'libxml2'

    pkg.build_requires 'libreadline-dev'
    pkg.requires 'libreadline6'

    pkg.build_requires 'pkg-config'
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
  end

  pkg.configure do
    [ "./configure --prefix=#{settings[:prefix]} #{settings[:host]}" ]
  end

  pkg.build do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install"]
  end
end
