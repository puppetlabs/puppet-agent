# This component exists to link in the gcc and stdc++ runtime libraries as well as libssp.
component "runtime" do |pkg, settings, platform|
  if platform.name =~ /solaris-10/
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-gcc-4.8.2-1.#{platform.architecture}.pkg.gz"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-binutils-2.25.#{platform.architecture}.pkg.gz"
  elsif platform.name =~ /huaweios|solaris-11/
    pkg.build_requires "pl-gcc-#{platform.architecture}"
  elsif platform.is_aix?
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-gcc-5.2.0-1.aix#{platform.os_version}.ppc.rpm"
    libdir = "/opt/pl-build-tools/lib/gcc/powerpc-ibm-aix#{platform.os_version}.0.0/5.2.0/"
  elsif platform.is_windows?
    # We only need zlib because curl is dynamically linking against zlib
    pkg.build_requires "pl-zlib-#{platform.architecture}"
  else
    pkg.build_requires "pl-gcc"
  end

  if platform.architecture == "sparc" || platform.name =~ /huaweios/
    libdir = File.join("/opt/pl-build-tools", settings[:platform_triple], "lib")
  elsif platform.is_solaris? || platform.architecture =~ /i\d86/
    libdir = "/opt/pl-build-tools/lib"
  elsif platform.architecture =~ /64/
    libdir = "/opt/pl-build-tools/lib64"
  end

  if platform.is_aix?
    pkg.install_file File.join(libdir, "libstdc++.a"), "/opt/puppetlabs/puppet/lib/libstdc++.a"
    pkg.install_file File.join(libdir, "libgcc_s.a"), "/opt/puppetlabs/puppet/lib/libgcc_s.a"
  elsif platform.is_windows?
    lib_type = platform.architecture == "x64" ? "seh" : "sjlj"
    pkg.install_file "#{settings[:gcc_bindir]}/libgcc_s_#{lib_type}-1.dll", "#{settings[:bindir]}/libgcc_s_#{lib_type}-1.dll"
    pkg.install_file "#{settings[:gcc_bindir]}/libstdc++-6.dll", "#{settings[:bindir]}/libstdc++-6.dll"
    pkg.install_file "#{settings[:gcc_bindir]}/libwinpthread-1.dll", "#{settings[:bindir]}/libwinpthread-1.dll"

    # Curl is dynamically linking against zlib, so we need to include this file until we
    # update curl to statically link against zlib
    pkg.install_file "#{settings[:tools_root]}/bin/zlib1.dll", "#{settings[:bindir]}/zlib1.dll"
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
