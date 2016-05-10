component "libxslt" do |pkg, settings, platform|
  pkg.version "1.1.28"
  pkg.md5sum "9667bf6f9310b957254fdcf6596600b7"
  pkg.url "http://buildsources.delivery.puppetlabs.net/#{pkg.get_name}-#{pkg.get_version}.tar.gz"

  pkg.build_requires "libxml2"

  if platform.is_aix?
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-gcc-5.2.0-1.aix#{platform.os_version}.ppc.rpm"
    pkg.environment "PATH" => "/opt/pl-build-tools/bin:$$PATH"
  elsif platform.is_huaweios? || platform.architecture == "s390x"
    pkg.environment "PATH" => "/opt/pl-build-tools/bin:$$PATH:#{settings[:bindir]}"
    pkg.environment "CFLAGS" => settings[:cflags]
    pkg.environment "LDFLAGS" => settings[:ldflags]

    # libxslt is picky about manually specifying the build host
    build = "--build x86_64-linux-gnu"
  elsif platform.is_solaris?
    pkg.environment "PATH" => "/opt/pl-build-tools/bin:$$PATH:/usr/local/bin:/usr/ccs/bin:/usr/sfw/bin:#{settings[:bindir]}"
    pkg.environment "CFLAGS" => settings[:cflags]
    pkg.environment "LDFLAGS" => settings[:ldflags]
    # Configure on Solaris incorrectly passes flags to ld
    pkg.apply_patch 'resources/patches/libxslt/disable-version-script.patch'
  elsif platform.is_osx?
    pkg.environment "LDFLAGS" => settings[:ldflags]
    pkg.environment "CFLAGS" => settings[:cflags]
  else
    pkg.build_requires "pl-gcc"
    pkg.build_requires "make"
    pkg.environment "LDFLAGS" => settings[:ldflags]
    pkg.environment "CFLAGS" => settings[:cflags]
  end

  if platform.name =~ /huaweios|solaris-11/ || platform.architecture == "s390x"
    pkg.build_requires "pl-gcc-#{platform.architecture}"
  end

  if platform.is_linux?
    if platform.architecture =~ /powerpc$/
      target = 'powerpc-linux-gnu'
    elsif platform.architecture =~ /ppc64le$/
      target = 'powerpc64le-unknown-linux-gnu'
    end
  end

  pkg.configure do
    ["./configure --prefix=#{settings[:prefix]} --docdir=/tmp --with-libxml-prefix=#{settings[:prefix]} #{settings[:host]} #{build} #{target}"]
  end

  pkg.build do
    ["#{platform[:make]} VERBOSE=1 -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    [
      "#{platform[:make]} VERBOSE=1 -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install",
      "rm -rf #{settings[:datadir]}/gtk-doc",
      "rm -rf #{settings[:datadir]}/doc/#{pkg.get_name}*"
    ]
  end

end
