component "virt-what" do |pkg, settings, platform|
  pkg.version "1.1.4"
  pkg.md5sum "4d9bb5afc81de31f66443d8674bb3672"
  pkg.url "http://buildsources.delivery.puppetlabs.net/virt-what-1.14.tar.gz"

  pkg.replaces 'pe-virt-what'

  # Run-time requirements
  unless platform.is_deb?
    requires "util-linux"
  end
  if platform.name =~ /^sles-(10|11)-.*$/
    # pmtools (which contains the dmidecode command) is not
    # available in the s390x repos
    requires "pmtools" unless platform.architecture == "s390x"
  end

  if platform.is_rpm?
    pkg.build_requires "util-linux"
  end

  if platform.is_linux?
    if platform.architecture =~ /ppc64le$/
      host_opt = '--host powerpc64le-unknown-linux-gnu'
    end
  end

  if platform.is_cross_compiled_linux?
    host_opt = '--host powerpc-linux-gnu' if platform.is_huaweios?
    host_opt = '--host s390x-linux-gnu' if platform.architecture == "s390x"

    pkg.environment "PATH" => "/opt/pl-build-tools/bin:$$PATH:#{settings[:bindir]}"
    pkg.environment "CFLAGS" => settings[:cflags]
    pkg.environment "LDFLAGS" => settings[:ldflags]
  end

  pkg.configure do
    ["./configure --prefix=#{settings[:prefix]} --sbindir=#{settings[:prefix]}/bin --libexecdir=#{settings[:prefix]}/lib/virt-what #{host_opt}"]
  end

  pkg.build do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install"]
  end
end
