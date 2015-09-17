# This component exists to link in the gcc and stdc++ runtime libraries as well as libssp.
component "runtime" do |pkg, settings, platform|
  if platform.name =~ /solaris-10/
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-gcc-4.8.2.#{platform.architecture}.pkg.gz"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-binutils-2.25.#{platform.architecture}.pkg.gz"
  elsif platform.is_aix?
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-gcc-5.2.0-1.aix#{platform.os_version}.ppc.rpm"
    libdir = "/opt/pl-build-tools/lib/gcc/powerpc-ibm-aix#{platform.os_version}.0.0/5.2.0/"
  else
    pkg.build_requires "pl-gcc"
  end

  if platform.architecture == "sparc"
    libdir = File.join("/opt/pl-build-tools", settings[:platform_triple], "lib")
  elsif platform.is_solaris? || platform.architecture =~ /i\d86/
    libdir = "/opt/pl-build-tools/lib"
  elsif platform.architecture =~ /64/
    libdir = "/opt/pl-build-tools/lib64"
  end

  if platform.is_aix?
    pkg.install_file File.join(libdir, "libstdc++.a"), "/opt/puppetlabs/puppet/lib/libstdc++.a"
    pkg.install_file File.join(libdir, "libgcc_s.a"), "/opt/puppetlabs/puppet/lib/libgcc_s.a"
  else
    pkg.install_file File.join(libdir, "libstdc++.so.6.0.18"), "/opt/puppetlabs/puppet/lib/libstdc++.so.6.0.18"
    pkg.install_file File.join(libdir, "libgcc_s.so.1"), "/opt/puppetlabs/puppet/lib/libgcc_s.so.1"
    pkg.install_file File.join(libdir, "libssp.so.0.0.0"), "/opt/puppetlabs/puppet/lib/libssp.so.0.0.0"

    pkg.link "/opt/puppetlabs/puppet/lib/libstdc++.so.6.0.18", "/opt/puppetlabs/puppet/lib/libstdc++.so"
    pkg.link "/opt/puppetlabs/puppet/lib/libstdc++.so.6.0.18", "/opt/puppetlabs/puppet/lib/libstdc++.so.6"
    pkg.link "/opt/puppetlabs/puppet/lib/libgcc_s.so.1", "/opt/puppetlabs/puppet/lib/libgcc_s.so"
    pkg.link "/opt/puppetlabs/puppet/lib/libssp.so.0.0.0", "/opt/puppetlabs/puppet/lib/libssp.so.0"
    pkg.link "/opt/puppetlabs/puppet/lib/libssp.so.0.0.0", "/opt/puppetlabs/puppet/lib/libssp.so"
  end
end
