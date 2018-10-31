# This component exists to link in the gcc and stdc++ runtime libraries as well as libssp.
component "runtime" do |pkg, settings, platform|
  pkg.add_source "file://resources/files/runtime/runtime.sh"

  if platform.name =~ /solaris-10/
    if platform.architecture == 'sparc'
      pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-gcc-4.8.2-9.#{platform.architecture}.pkg.gz"
      pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-binutils-2.27-2.#{platform.architecture}.pkg.gz"
    else
      pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-gcc-4.8.2-1.#{platform.architecture}.pkg.gz"
      pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-binutils-2.27-1.#{platform.architecture}.pkg.gz"
    end
  elsif platform.is_cross_compiled_linux? || platform.name =~ /solaris-11/
    pkg.build_requires "pl-binutils-#{platform.architecture}"
    pkg.build_requires "pl-gcc-#{platform.architecture}"
    pkg.build_requires "pl-binutils-#{platform.architecture}"
  elsif platform.is_aix?
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-gcc-5.2.0-11.aix#{platform.os_version}.ppc.rpm"
    libdir = "/opt/pl-build-tools/lib/gcc/powerpc-ibm-aix#{platform.os_version}.0.0/5.2.0/"
  elsif platform.is_windows?
    pkg.build_requires "pl-gdbm-#{platform.architecture}"
    pkg.build_requires "pl-iconv-#{platform.architecture}"
    pkg.build_requires "pl-libffi-#{platform.architecture}"
    pkg.build_requires "pl-pdcurses-#{platform.architecture}"
    # We only need zlib because curl is dynamically linking against zlib
    pkg.build_requires "pl-zlib-#{platform.architecture}"
  elsif platform.name =~ /sles-15|osx-10.12/
    # These platforms use their default OS toolchain and have package
    # dependencies configured in the platform provisioning step.
  else
    pkg.build_requires "pl-gcc"
  end

  if platform.is_cross_compiled?
    libdir = File.join("/opt/pl-build-tools", settings[:platform_triple], "lib")
    libdir = File.join("/opt/pl-build-tools", settings[:platform_triple], "lib64") if platform.architecture =~ /aarch64|s390x|ppc64/
  elsif platform.is_solaris? || platform.architecture =~ /i\d86/
    libdir = "/opt/pl-build-tools/lib"
  elsif platform.architecture =~ /64/
    libdir = "/opt/pl-build-tools/lib64"
  end

  # The runtime script uses readlink, which is in an odd place on Solaris systems:
  pkg.environment "PATH", "$(PATH):/opt/csw/gnu" if platform.is_solaris?

  if platform.is_aix?
    pkg.install_file File.join(libdir, "libstdc++.a"), "/opt/puppetlabs/puppet/lib/libstdc++.a"
    pkg.install_file File.join(libdir, "libgcc_s.a"), "/opt/puppetlabs/puppet/lib/libgcc_s.a"
  elsif platform.is_macos?
    # Nothing to see here
  elsif platform.is_windows?
    lib_type = platform.architecture == "x64" ? "seh" : "sjlj"
    pkg.install_file "#{settings[:gcc_bindir]}/libgcc_s_#{lib_type}-1.dll", "#{settings[:bindir]}/libgcc_s_#{lib_type}-1.dll"
    pkg.install_file "#{settings[:gcc_bindir]}/libstdc++-6.dll", "#{settings[:bindir]}/libstdc++-6.dll"
    pkg.install_file "#{settings[:gcc_bindir]}/libwinpthread-1.dll", "#{settings[:bindir]}/libwinpthread-1.dll"
    pkg.install_file "#{settings[:gcc_bindir]}/libgcc_s_#{lib_type}-1.dll", "#{settings[:facter_root]}/lib/libgcc_s_#{lib_type}-1.dll"
    pkg.install_file "#{settings[:gcc_bindir]}/libstdc++-6.dll", "#{settings[:facter_root]}/lib/libstdc++-6.dll"
    pkg.install_file "#{settings[:gcc_bindir]}/libwinpthread-1.dll", "#{settings[:facter_root]}/lib/libwinpthread-1.dll"

    # Curl is dynamically linking against zlib, so we need to include this file until we
    # update curl to statically link against zlib
    pkg.install_file "#{settings[:tools_root]}/bin/zlib1.dll", "#{settings[:ruby_bindir]}/zlib1.dll"

    # gdbm, yaml-cpp and iconv are all runtime dependancies of ruby, and their libraries need
    # To exist inside our vendored ruby
    pkg.install_file "#{settings[:tools_root]}/bin/libgdbm-4.dll", "#{settings[:ruby_bindir]}/libgdbm-4.dll"
    pkg.install_file "#{settings[:tools_root]}/bin/libgdbm_compat-4.dll", "#{settings[:ruby_bindir]}/libgdbm_compat-4.dll"
    pkg.install_file "#{settings[:tools_root]}/bin/libiconv-2.dll", "#{settings[:ruby_bindir]}/libiconv-2.dll"
    pkg.install_file "#{settings[:tools_root]}/bin/libffi-6.dll", "#{settings[:ruby_bindir]}/libffi-6.dll"

  else # Linux and Solaris systems
    pkg.install do
      "bash runtime.sh #{libdir}"
    end
  end
end
